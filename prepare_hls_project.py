"""
Contains functions for building a Vivado HLS project that implements a set of Java methods.
build_from_functions is the main function that should be called to perform the entire process.
"""

import os, shutil

from pycparser import c_ast

from flowanalysis import ReachableFunctions, get_files_to_search
from juniperrewrites import c_prototype_of_java_sig, c_decl_node_of_java_sig, rewrite_source_file
import juniperrewrites
from utils import log, mkdir, copy_files


def build_from_functions(funcs, jamaicaoutputdir, outputdir, additionalsourcefiles, part, notranslatesigs):
	"""
	Build a Vivado HLS project that contains the hardware for a set of Java functions
	
	Args:
		funcs: Iterable of strings of Java signatures that are the methods to include
		jamaicaoutputdir: Absolute path of the Jamaica builder output directory (that contains the generated C code)
		outputdir: Absolute path of the target directory in which to build the project. Will be created if does not exist.
		additionalsourcefiles: Iterable of abs paths for other source files that are required.
		part: The FPGA part to target. Passed directly to the Xilinx tools and not checked.
		notranslatesigs: Signatures of methods that should not be translated
	Returns:
		A dictionary of {int -> Java sig} of the hardware methods and their associated call ids.
	"""
	filestobuild = set()
	cwd = os.path.dirname(os.path.realpath(__file__))	
	filestobuild.append(os.path.join(cwd, "projectfiles", "src", "fpgaporting.c"))
	
	#All functions that should be translated
	all_reachable_functions = set() 
	#Reachable functions that have been excluded by flowanalysis.excluded_functions so need to be handled as a PCIe interrupt
	reachable_non_translated = set() 
		
	for sig in funcs:
		filestosearch = get_files_to_search(sig, jamaicaoutputdir)
		
		if additionalsourcefiles != None:
			for f in additionalsourcefiles: 
				if not f in filestosearch: filestosearch.append(f)
				if not f in filestobuild: filestobuild.append(f)

		funcdecl = c_decl_node_of_java_sig(sig, jamaicaoutputdir)
		rf = ReachableFunctions(funcdecl.parent, filestosearch)
		
		#Don't forget to include the starting point
		all_reachable_functions.append(funcdecl.parent)
		if not funcdecl.parent.coord.file in filestobuild: filestobuild.append(funcdecl.parent.coord.file)

		for f in rf.files: filestobuild.append(f)
		for f in rf.reachable_functions: all_reachable_functions.append(f)
		for r in rf.reachable_non_translated: reachable_non_translated.append(r)
		
	log().info("All reachable functions:")
	for f in all_reachable_functions:
		log().info("\t" + str(f.decl.name) + ": " + str(f.coord.file))
		
	#Build the syscall structure
	#TODO: notranslatedecls is not currently used
	notranslatedecls = determine_no_translate_fns(all_reachable_functions, notranslatesigs)
	callid = 1
	syscalls = {}
	for sysname in reachable_non_translated:
		syscalls[sysname] = callid
		callid = callid + 1
	if len(syscalls) > 0:
		log().info("Generating syscalls for:")
		for callname, sysid in syscalls.iteritems():
			log().info("\t" + str(sysid) + ": " + str(callname))
	
	copy_project_files(outputdir, jamaicaoutputdir, part, filestobuild, all_reachable_functions, syscalls)
	
	write_toplevel_header(funcs, jamaicaoutputdir, os.path.join(outputdir, "include", "toplevel.h"))
	bindings = write_functions_c(funcs, jamaicaoutputdir, os.path.join(outputdir, "src", "functions.c"))
	write_hls_script(os.path.join(outputdir, "src"), part, os.path.join(outputdir, "script.tcl"))
	return bindings


def copy_project_files(targetdir, jamaicaoutputdir, fpgapartname, filestobuild, reachable_functions, syscalls):
	"""
	Prepare an HLS project. Copies all required files from the local 'projectfiles' dir into targetdir
	along with any extra required files.
	Args:
		targetdir: directory to output to
		jamaicaoutputdir: absolute path that contains the output of Jamaica builder
		fgpapartname: string of the fpga part name
		filestobuild: array of absolute file paths and will be added to the HLS tcl script as source files
		reachable_functions: array of FuncDecl nodes that are reachable and require translation
		syscalls: map{string->int} names of function calls that should be translated to PCIe system calls -> ID of call
	"""
	cwd = os.path.dirname(os.path.realpath(__file__))	
	mkdir(targetdir)
	copy_files(os.path.join(cwd, "projectfiles", "include"), os.path.join(targetdir, "include"), [".h"])
	copy_files(os.path.join(cwd, "projectfiles", "src"), os.path.join(targetdir, "src"), [".h", ".c"])
	shutil.copy(os.path.join(jamaicaoutputdir, "Main__.h"), os.path.join(targetdir, "include"))

	for f in filestobuild:
		if not os.path.basename(f) == "fpgaporting.c": #We needed fpgaporting to perform reachability analysis, but don't rewrite it
			log().info("Adding source file: " + f)
			if f.endswith(".c"): #We only parse C files
				targetfile = os.path.join(targetdir, "src", os.path.basename(f))
				rewrite_source_file(f, targetfile, reachable_functions, syscalls)
		

	
def write_hls_script(targetsrcdir, fpgapartname, outputfilename):
	"""
	Prepare the TCL script which will control HLS.
	All .cpp, .c or .h files in targetsrcdir will be added as sources in the script, so 
	this should be called after rest of the project has been set up.
	"""
	s = "open_project prj\n"
	s = s + "set_top hls\n"
	
	for f in os.listdir(targetsrcdir):
		abspath = os.path.join(targetsrcdir, f)
		if os.path.isfile(abspath):
			#Only bother adding HLS-supported file types
			if abspath.endswith(".cpp") or abspath.endswith(".c") or abspath.endswith(".h"):
				s = s + 'add_files src/' + f + ' -cflags "-Iinclude/."\n'
				
	s = s + 'open_solution "solution1"\n'
	s = s + 'set_part {' + fpgapartname + '}\n'
	s = s + 'create_clock -period 10 -name default\n'
	s = s + 'csynth_design\n'
	s = s + 'export_design -format ip_catalog\n'

	script = open(outputfilename, "w")
	script.write(s)
	script.close()


def get_paramlist_of_sig(sig, jamaicaoutputdir):
	"""
	Given a Java signature, find the corresponding C function declaration in the AST
	and then parse to the parameter list. Returns a c_ast.ParamList or None in the
	case of an error.
	"""
	declnode = c_decl_node_of_java_sig(sig, jamaicaoutputdir)
	funcdecl = declnode.children()[0][1]
	if not isinstance(funcdecl, c_ast.FuncDecl):
		raise juniperrewrites.CaicosError("Unexpected function declaration format for signature " + str(sig) + ". Expected FuncDecl, got " + type(funcdecl).__name__)
	paramlist = funcdecl.children()[0][1]
	if not isinstance(paramlist, c_ast.ParamList):
		raise juniperrewrites.CaicosError("Unexpected function declaration format for signature " + str(sig) + ". Expected ParamList, got " + type(funcdecl).__name__)
	return paramlist
	

def get_args_max(functions, jamaicaoutputdir):
	"""
	Look through the functions in the generated code to determine the largest number of arguments any one has
	"""
	maxseen = 0
	for sig in functions:
		paramlist = get_paramlist_of_sig(sig, jamaicaoutputdir)
		maxseen = max([maxseen, len(paramlist.params)])
	return maxseen


def write_toplevel_header(functions, jamaicaoutputdir, outputfile):
	"""
	Prepare the header for the toplevel .cpp file.
	This is a simple header guard, then the prototypes of the functions passed in
	functions = [java_signatures_of_functions_to_prototype]
	"""
	s = 	"#ifndef TOPLEVEL_H_\n"
	s = s + "#define TOPLEVEL_H_\n"
	s = s + "\n"
	s = s + "#include <jamaica.h>\n"
	s = s + "\n"
	s = s + "#define ARGS_MAX " + str(get_args_max(functions, jamaicaoutputdir))
	s = s + "\n"
	for f in functions:
		s = s + c_prototype_of_java_sig(f, jamaicaoutputdir) + "\n"
	s = s + "\n"
	s = s + "#endif /* TOPLEVEL_H_ */\n"
	hfile = open(outputfile, "w")
	hfile.write(s)
	hfile.close()



def call_code_for_sig(sig, jamaicaoutputdir):
	"""
	Given a Java signature, return the code to call the translated C version of it, to be 
	placed in functions.cpp.
	Note: This function doesn't check the AST structure. This IS checked in get_paramlist_of_sig 
	so something will error if the AST is wrong, but this in general assumes a well-formed AST.
	"""
	declnode = c_decl_node_of_java_sig(sig, jamaicaoutputdir)
	funcdecl = declnode.children()[0][1]
	paramlist = funcdecl.children()[0][1]
	rv = declnode.name + "("
	
	paramnum = 0
	for pid in xrange(len(paramlist.params)):
		#Insert an explicit cast to the target type
		#Handles single-stage pointers and base types only, no arrays, because
		#it is believed that this is all that Jamaica builder will output.
		prm = paramlist.params[pid]
		pointer = False
		if isinstance(prm.type, c_ast.PtrDecl):
			pointer = True
			pdec = prm.type.type
		else:
			pdec = prm.type
			
		if pointer and pdec.type.names[0] == "jamaica_thread":
			rv = rv + "&__juniper_thread"
		else:  					
			rv = rv + "(" + str(pdec.type.names[0])
			if pointer: rv = rv + "*"
			rv = rv + ") "
			rv = rv + "__juniper_args[" + str(paramnum) + "]"
			paramnum = paramnum + 1
			
		if not pid == len(paramlist.params) - 1:
			rv = rv + ", "
			
	rv = rv + ");" 
	return rv



def write_functions_c(functions, jamaicaoutputdir, outputfile):
	"""
	Prepare functions.c, which contains the dispatch functions that calls the translated methods.
	"""
	bindings = {}
	callid = 0
	
	s =     "#include <jamaica.h>\n"
	s = s + "#include <toplevel.h>\n"
	s = s + "#include <Main__.h>\n"
	s = s + "\n"
	s = s + "int __juniper_call(int call_id) {\n"
	s = s + "\tswitch(call_id) {\n"
	
	for f in functions:
		bindings[callid] = f #Note the binding of index to function
		s = s + "\t\tcase " + str(callid) + ":\n"
		
		#The return type affects how we call it
		#TODO: Currently 64-bit return types are not supported
		declnode = c_decl_node_of_java_sig(f, jamaicaoutputdir)
		returntype = str(declnode.type.type.type.names[0])
		if returntype == "void":
			s = s +"\t\t\t" + str(call_code_for_sig(f, jamaicaoutputdir)) + "\n"
			s = s + "\t\t\treturn 0;\n"
		elif returntype in ['float', 'jamaica_float']:
			s = s + "\t\t\t" + returntype + " rv;\n"
			s = s + "\t\t\trv = " + str(call_code_for_sig(f, jamaicaoutputdir)) + "\n"
			s = s + "\t\t\treturn *(int *)&rv;"
		else:
			s = s + "\t\t\treturn (int) " + str(call_code_for_sig(f, jamaicaoutputdir)) + "\n"
		s = s +"\n"
		callid = callid + 1
		
	s = s + "\t\tdefault:\n"
	s = s + "\t\t\treturn 0;\n"
	s = s + "\t}\n"
	s = s + "}\n"
	hfile = open(outputfile, "w")
	hfile.write(s)
	hfile.close()
	return bindings



def determine_no_translate_fns(all_reachable_functions, notranslatesigs):
	"""
	Return an array which is a subset of all_reachable_functions for the functions that 
	the user has configured to not be translated and therefore implemented as a PCIe 
	interrupt to the host.
	"""
	rv = set()	
	for funcdef in all_reachable_functions:
		details = juniperrewrites.get_java_names_of_funcdef(funcdef)
		if details != None and details[0] in notranslatesigs:
			rv.add(funcdef)
			
	return rv
	
