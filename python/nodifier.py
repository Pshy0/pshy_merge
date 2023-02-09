#!/usr/bin/python3
from tokens import *
from pprint import pprint
import sys
#TODO: add a function returning the Type2 (with "<>") to tokens



LUA_GROUP_OPENERS = {
	"<module>": "<eof>",
	"{": "}",
	"(": ")",
	"[": "]",
	"do": "end",
	"while": "do",
	"for": ["in", "do"],
	"in": "do",
	"repeat": "until",
	"until": "<statend>",
	"if": "then",
	"then": ["elseif", "else", "end"],
}



class TokenGroup:
	
	def __init__(self, mytype):
		self.type = mytype
		self.tokens = []
	
	def Complete(self, tokens, i_token):
		token = tokens[i_token]
		token_type2 = token.Type2()
		closers = LUA_GROUP_OPENERS[self.type]
		if not token_type2 in LUA_GROUP_OPENERS:
			self.tokens.append(token)
		if token_type2 in closers:
			return True
		else:
			return False
			
		if not token_type2 in closers:
			self.tokens.append(token)
			return False
		# closing
		if not token_type2 in LUA_GROUP_OPENERS:
			print("APPEND `{}`3".format(str(token)))
			self.tokens.append(token)
		print("COMPLETED")
		return True
	
	def GetMeaninglessPrefix(self):
		return self.tokens[0].GetMeaninglessPrefix()

	def __str__(self):
		total = ""
		for token in self.tokens:
			token_str = str(token)
			if len(token_str) > 0:
				if len(total) > 0 and total[-1] in LUA_IDENTIFIER_CHARS and token_str[0] in LUA_IDENTIFIER_CHARS:
					if token.GetMeaninglessPrefix().find("\n") > -1:
						total += "\n"
					else:
						total += " "
				total += token_str
		return total

	def Tree(self):
		total = []
		for token in self.tokens:
			if isinstance(token, TokenGroup):
				total.append(token.Tree())
			else:
				total.append(str(token))
		return total



def GetNewTokenGroup(tokens, i_token):
	token = tokens[i_token]
	token_type2 = token.Type2()
	if token_type2 in LUA_GROUP_OPENERS:
		grp = TokenGroup(token_type2)
		grp.tokens.append(token)
		return grp



def Nodify(tokens):
	node_stack = []
	node_stack.append(TokenGroup("<module>"))
	i_token = 0
	while len(node_stack) > 0:
		current_grp = node_stack[-1]
		if current_grp.Complete(tokens, i_token):
			print("POPPING " + current_grp.type + " ({})".format(len(node_stack)))
			node_stack.pop()
			if len(node_stack) == 0:
				return current_grp
			else:
				node_stack[-1].tokens.append(current_grp)
		new_grp = GetNewTokenGroup(tokens, i_token)
		if new_grp != None:
			print("APPENING " + new_grp.type + " ({})".format(len(node_stack)))
			node_stack.append(new_grp)
		i_token += 1



def Main(argc, argv):
	source = r"""
local variable_nana = {}
s = 18
--- This is some module code
-- it's not important
local function faaa()
    a = 4
    global_aaaaaa  =  5.4 -- why do i do that
        for i = 1, aaa do end
        for i, v in ipairs(nana) do end
    local local_bbbb  =  "because\" i can"
     global_c  =  [[am i sure about that]]
    print(tostring(global_aaaaaa) .. local_bbbb ..  global_c)
    variable_nana = variable_nana or 4
    variable_nana.di = 4.6
end
--[[ multiline
 comment to
serve you]]
 faaa()
return false
"""
	tokens = TokenizeMeaningful(source)
	module = Nodify(tokens)
	print("")
	print(str(module))
	print("")
	pprint(module.Tree(), indent = 4)



if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
