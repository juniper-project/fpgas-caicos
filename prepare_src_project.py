'''
Contains functions to prepare the source project that will execute on the host OS and interact 
with the hardware which is generated by prepare_hls_project

build_src_project is the main entry point to this module
@author: ian
'''
import os
from os.path import join
import shutil

from pycparser import c_ast

import astcache
import flowanalysis
from juniperrewrites import c_filename_of_java_method_sig, \
	c_decl_node_of_java_sig, get_line_bounds_for_function, c_name_of_type
import juniperrewrites
from prepare_hls_project import get_paramlist_of_sig
from utils import CaicosError, mkdir, copy_files, project_path


def build_src_project(bindings, jamaicaoutput, targetdir, syscalls):
	"""
	Construct the software portion of the project. Copy the C source code for the Jamaica project, 
	refactoring the functions that are implemented on the FPGA.
	Also copies the FPGA interface and build scripts. 
	
	bindings:
		A map {id -> java method signature} that gives the ID of each hardware method. 
		Generated from prepare_hls_project.build_from_functions
	jamaicaoutput:
		Absolute path of the jamaica builder output directory which contains the source C files
	targetdir:
		Absolute path to place output files
	"""
	if not os.path.isfile(join(jamaicaoutput, "Main__nc.o")):
		raise CaicosError("Cannot find file " + str(join(jamaicaoutput, "Main__nc.o")) + 
						". Ensure that the application has first be been built by Jamaica Builder.")
		
	mkdir(targetdir)
	copy_files(project_path("projectfiles", "juniper_fpga_interface"), join(targetdir, "juniper_fpga_interface"))
	copy_files(project_path("projectfiles", "malloc_preload"), join(targetdir, "malloc_preload"))
	refactor_src(bindings, jamaicaoutput, join(targetdir, "src"))
	generate_interrupt_handler(join(targetdir, "src", "caicos_interrupts.c"), syscalls)
	shutil.copy(join(jamaicaoutput, "Main__nc.o"), join(targetdir, "src"))
	shutil.copy(project_path("projectfiles", "include", "juniperoperations.h"), join(targetdir, "src"))


def refactor_src(bindings, jamaicaoutput, targetdir):
	"""
	Copy the C source code for the Jamaica project. For files that contain functions that have
	been implemented on the FPGA, replace their contents with code to invoke the FPGA instead.
	
	Outputs files to targetdir
	"""
	
	#Which are the C files we will need to rewrite?
	filestoedit = set()
	for _, sig in bindings.iteritems():
		filestoedit.add(c_filename_of_java_method_sig(sig, jamaicaoutput))
		
	#Copy the C files over, rewriting those that contain functions we have passed to the hardware
	mkdir(targetdir)
	for item in os.listdir(jamaicaoutput):
		filepath = os.path.join(jamaicaoutput, item)
		if os.path.isfile(filepath) and (filepath.endswith(".c") or filepath.endswith(".h")):
			if not filepath in filestoedit:
				#Just copy the file, no edits required
				shutil.copy(filepath, targetdir)
			else:
				#Any previous edits to the AST need to be disregarded
				astcache.invalidate_ast_for(filepath)

				#Which sigs are in this file?
				toreplace = []
				for callid, sig in bindings.iteritems():
					if c_filename_of_java_method_sig(sig, jamaicaoutput) == filepath:
						decl = c_decl_node_of_java_sig(sig, jamaicaoutput)
						bounds = get_line_bounds_for_function(decl)
						toreplace.append((bounds, callid, sig, decl))

				toreplace.sort() #Sort by ascending line number

				filecontents = open(filepath).readlines()
				output = "#include <juniper_fpga_interface.h>\n#include <juniperoperations.h>\n\n"
				output += "extern void caicos_handle_pcie_interrupt(jamaica_thread *ct, int devNo, int partNo);\n\n"
				lineno = 1

				for bounds, callid, sig, decl in toreplace:
					while lineno <= bounds[0]:
						output = output + filecontents[lineno-1]
						lineno += 1
					
					output += "\t//~~~~~~~~~~~~~~~~" + str(sig) + "  " + str(bounds) + "~~~~~~~~~~~~~~~~~~~~~\n"
					output += "\t" + str(generate_replacement_code(sig, decl, callid, jamaicaoutput, (0, 0)))
					
					if bounds[1] == None:
						output += "}\n\n#else\n#error 'jamaica.h' not found!\n#endif\n\n#ifdef __cplusplus\n}\n#endif\n"
					else:
						output += "}\n"
						lineno = bounds[1] + 1
				
				with open(os.path.join(targetdir, item), "w") as outf:
					outf.write(output)


def generate_replacement_code(java_sig, decl, callid, jamaicaoutput, device):
	"""
	Generate C code for the host which replaces the provided Decl node. The generated
	code invokes the FPGA and calls the hardware call that has id callid  
	
	java_sig:
		Java signature from which this function was generated
	decl:
		c_ast.Decl node of the function declaration we are rewriting
	callid:
		ID of the hardware call that we are generating for
	jamaicaoutput:
		Absolute path of the jamaica builder output directory which contains the source C files
	device:
		pair (device_id, part_id) that describes the hardware accelerator to use 
	"""
	devNoPartNo = str(device[0]) + ", " + str(device[1]) 
	
	def fpga_set_arg(argNo, val):
		return r"	juniper_fpga_partition_set_arg(" + devNoPartNo + ", " + str(argNo) + ", " + str(val) + ");\n"

	def fpga_retval(rv):
		return r"	juniper_fpga_partition_get_retval(" + devNoPartNo + ", " + str(rv) + ");\n"
		
	def fpga_run():
		code = "	juniper_fpga_partition_start(" + devNoPartNo + ");\n"
		code += "	while(1) {\n" 
		code += "		if(juniper_fpga_partition_idle(" + devNoPartNo + ")) {\n\t\t\tbreak;\n\t\t}\n"
		code += "		if(juniper_fpga_partition_interrupted(" + devNoPartNo + ") {\n\t\t\tcaicos_handle_pcie_interrupt(ct, " + devNoPartNo + ");\n\t\t}\n"
		code += "	}\n"
		return code
	
	def fpga_set_base():
		code = "int *base = malloc(0);\n"
		code += "\tint rv;\n\n"
		code += "\tjuniper_fpga_partition_set_mem_base(" + devNoPartNo + ", -((int) base));\n"
		return code

	code = fpga_set_base()

	#Set up the arguments for the call
	params = get_paramlist_of_sig(java_sig, jamaicaoutput)
	firstarg = True
	for pnum in xrange(len(params.params)):
		paramname = params.params[pnum].name
		typename = c_name_of_type(params.params[pnum].type)

		if typename == "*jamaica_thread" and paramname == "ct":
			#All functions start with a reference to the current thread and can be ignored by the FPGA
			pass
		else:
			if firstarg: 
				code += fpga_set_arg(0, "OP_WRITE_ARG")
				firstarg = False
			code += fpga_set_arg(1, pnum)
			
			if typename in ["jamaica_int8", "jamaica_int16", "jamaica_int32", "jamaica_uint8", "jamaica_uint16", "jamaica_uint32", "jamaica_bool"]:
				code += fpga_set_arg(2, paramname)
			elif typename == "jamaica_ref":
				code += fpga_set_arg(2, "(int)" + paramname + " / 4")
			elif typename == "jamaica_float":
				code += fpga_set_arg(2, "*((int *) &" + paramname + ")")
			elif typename == "jamaica_address":
				code += fpga_set_arg(2, paramname)
			elif typename in ["jamaica_int64", "jamaica_uint64"]:
				#TODO
				pass
				#code += fpga_set_arg(2, paramname)
			elif typename == "jamaica_double":
				#TODO
				pass
				#code += fpga_set_arg(2, paramname)
			else:
				raise CaicosError("Unknown type " + str(typename) + " in function " + str(java_sig))

			code += fpga_run() + "\n"
			
	code += fpga_set_arg(0, "OP_CALL") + fpga_set_arg(1, callid) + fpga_run() + "\n"
	
	#Do we need a return value?
	rettype = decl.type.type.type.names[0]
	if rettype == "void":
		code += "	return;\n"
	elif rettype in ["jamaica_int8", "jamaica_int16", "jamaica_int32", 
					"jamaica_uint8", "jamaica_uint16", "jamaica_uint32", 
					"jamaica_bool"
					"jamaica_ref", "jamaica_address"
					]:
		code += fpga_retval("&rv")
		code += "	return rv;\n"
	elif rettype == "jamaica_float":
		code += fpga_retval("&rv")
		code += "	return *((float *)(&rv));\n"
	elif rettype in ["jamaica_int64", "jamaica_uint64"]:
		#TODO
		code += "	return 0;\n"
	elif rettype == "jamaica_double":
		#TODO
		code += "	return 0;\n"
	else:
		raise CaicosError("Unknown return type " + str(typename) + " in function " + str(java_sig))
	
	return code


def generate_interrupt_handler(outputfile, syscalls):
	code = """#include <juniper_fpga_interface.h>
#include <juniperoperations.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <jamaica.h>
#include <jni.h>
#include <jbi.h>
#include "Main__.h"

void caicos_handle_pcie_interrupt(jamaica_thread *ct, int devNo, int partNo) {
	int rv = 0;
	juniper_fpga_syscall_args args;
	memset(&args, 0, sizeof(juniper_fpga_syscall_args));
	rv = juniper_fpga_partition_get_syscall_args(devNo, partNo, &args);
	
	if(rv != JUNIPER_FPGA_OK)
		fprintf(stderr, "Failed to open syscall file with code %d.\\n", rv);
		
	switch(args.cmd) {
"""

	for funcname, fid in syscalls.iteritems():
		funcdecl = flowanalysis.get_funcdecl_of_system_funccall(funcname)
		
		code += "\t\tcase " + str(fid) + ":\n"
		
		#Maybe cast the return type
		
		
		code += "\t\t\trv = " + funcname + "(ct, "
		
		paramlist = funcdecl.children()[0][1]
		for pid in xrange(1, len(paramlist.params)): #Skip the CT argument which is already handled
			prm = paramlist.params[pid]
			pointer = False
			if isinstance(prm.type, c_ast.PtrDecl):
				pointer = True
				pdec = prm.type.type
			else:
				pdec = prm.type
									
			code += "(" + str(pdec.type.names[0])
			if pointer: 
				code += "*"
			code += ") "
			code += "args.arg" + str(pid) #Handily, the args are numbered from arg1 so skipping 0 above works here
				
			if not pid == len(paramlist.params) - 1:
				code += ", "
		code += ");\n"
		code += "\t\t\tbreak;\n"

	code += """
		default:
			rv = -1;
			break;
	}
	
	juniper_fpga_partition_set_syscall_return(devNo, partNo, rv);
}
"""
	
	with open(outputfile, "w") as outf:
		outf.write(code)
