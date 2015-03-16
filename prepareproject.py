"""
Contains functions for building a Vivado HLS project that implements a set of Java methods.
build_from_functions is the main function that should be called to perform the entire process.
"""

import os, shutil
import sys

from pycparser import c_ast

from juniperrewrites import c_prototype_of_java_sig, c_decl_node_of_java_sig, \
	c_filename_of_java_method_sig, rewrite_source_file
from utils import log


def build_from_functions(funcs, jamaicaoutputdir, outputdir, part):
	"""
	Build a Vivado HLS project that contains the hardware for a set of Java functions
	
	Args:
		funcs: Iterable of strings of Java signatures that are the methods to include
		jamaicaoutputdir: Absolute path of the Jamaica builder output directory (that contains the generated C code)
		outputdir: Absolute path of the target directory in which to build the project. Will be created if does not exist.
		part: The FPGA part to target. Passed directly to the Xilinx tools and not checked.
	"""
	files = []
	for sig in funcs:
		f = c_filename_of_java_method_sig(sig, jamaicaoutputdir)
		if f == None:
			log().error("Could not find file for signature " + sig) 
			sys.exit(-1)
		if not f in files:
			files = files + [f]
	copy_project_files(outputdir, part, files)
	write_toplevel_header(funcs, jamaicaoutputdir, os.path.join(outputdir, "include", "toplevel.h"))
	write_functions_cpp(funcs, jamaicaoutputdir, os.path.join(outputdir, "src", "functions.cpp"))
	write_hls_script(os.path.join(outputdir, "src"), part, os.path.join(outputdir, "script.tcl"))


def copy_project_files(targetdir, fpgapartname, extrasourcefiles):
	"""
	Prepare an HLS project. Copies all required files from the local 'projectfiles' dir into targetdir
	along with any extra required files.
	extrasourcefiles is an array of absolute file paths and will be added to the HLS tcl script as source files
	"""
	def mkdir(d): 
		if not os.path.exists(d): os.makedirs(d);
		
	def copy_files(srcdir, targetdir, suffixes):
		mkdir(targetdir)
		for f in os.listdir(srcdir):
			abspath = os.path.join(srcdir, f)
			if os.path.isfile(abspath):
				for suff in suffixes:
					if abspath.endswith(suff):
						shutil.copyfile(abspath, os.path.join(targetdir, f))
						break

	cwd = os.path.dirname(os.path.realpath(__file__))	
	mkdir(targetdir)
	copy_files(os.path.join(cwd, "projectfiles", "include"), os.path.join(targetdir, "include"), [".h"])
	copy_files(os.path.join(cwd, "projectfiles", "src"), os.path.join(targetdir, "src"), [".h", ".cpp"])
	copy_files(os.path.join(cwd, "projectfiles"), targetdir, [".sh"])
	
	for f in extrasourcefiles:
		log().info("Adding source file: " + f)
		if f.endswith(".c"): #We only parse C files
			rewrite_source_file(f, os.path.join(targetdir, "src", os.path.basename(f)))
	

	
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
		log().error("Unexpected function declaration format for signature " + str(sig) + ". Expected FuncDecl, got " + type(funcdecl).__name__)
		return None
	paramlist = funcdecl.children()[0][1]
	if not isinstance(paramlist, c_ast.ParamList):
		log().error("Unexpected function declaration format for signature " + str(sig) + ". Expected ParamList, got " + type(funcdecl).__name__)
		return None
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
		rv = rv + "("
		if pointer: rv = rv + "*"
		rv = rv + pdec.type.names[0] + ") "
		
		rv = rv + "__juniper_args[" + str(pid) + "]"
		if not pid == len(paramlist.params) - 1:
			rv = rv + ", "
			
	rv = rv + ");" 
	return rv


def write_functions_cpp(functions, jamaicaoutputdir, outputfile):
	"""
	Prepare functions.cpp, which contains the dispatch functions that calls the translated methods.
	"""
	bindings = {}
	callid = 0
	
	s = "#include <toplevel.h>\n"
	s = s + "\n"
	s = s + "int __juniper_call(int call_id) {\n"
	s = s + "\tswitch(call_id) {\n"
	
	for f in functions:
		bindings[callid] = f #Note the binding of index to function
		s = s + "\t\tcase " + str(callid) + ":\n"
		s = s +"\t\t\treturn (int) " + str(call_code_for_sig(f, jamaicaoutputdir)) + "\n"
		s = s +"\n"
		callid = callid + 1
		
	s = s + "\t\tdefault:\n"
	s = s + "\t\t\treturn 0;\n"
	s = s + "\t}\n"
	s = s + "}\n"
	hfile = open(outputfile, "w")
	hfile.write(s)
	hfile.close()
