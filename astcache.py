"""
The ASTCache module helps to prevent unnecessary re-parsing, which can be 
very slow when using pycparser.

Maintains a dictionary of {filenames -> ASTs}

Call get(filename) to get an AST. The file will be parsed if this is the
first request, otherwise the previously generated AST will be returned.   

If code is being modified invalidate_ast_for(filename) can be used to 
remove a cached AST and force a reparse.
"""

from pycparser.plyparser import ParseError

from utils import log, CaicosError
import utils


cache = {}

def get(filename, alternateincludepath = None):
	try:
		if filename in cache:
			return cache[filename]
		else:
			log().info("Parsing " + filename)
			ast = utils.parse_jamaica_output(filename, alternateincludepath)
			add_parent_links(ast)
			cache[filename] = ast
			return ast
	except ParseError, pe:
		raise CaicosError("Parse error in file '" + str(filename) + "'.\n\t" + str(pe.message))
		
def invalidate_ast_for(filename):
	if filename in cache:
		del cache[filename]

def clear():
	cache.clear()

	
def add_parent_links(ast):
	"""
	Iterate over an AST annotating every node with a link to its parent node.
	"""
	def recurse(node, parent):
		node.parent = parent
		for _, c in node.children():
			recurse(c, node)
	recurse(ast, None)



	