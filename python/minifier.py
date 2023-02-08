#!/usr/bin/python3
import sys
import re

from .tokens import *



class LUAMinifier:

    def __init__(self):
        self.m_tokens = []
        self.m_minify_comments = False
        self.m_minify_spaces = False
        self.m_minify_unreadable = False
        self.m_minify_strings = False
        self.m_minify_strings_local_count = 120
        self.m_minify_locals = False
        self.m_obfuscate = False

    def LoadModule(self, source):
        self.m_tokens = Tokenize(source)

    def MinifyComments(self):
        for i in range(len(self.m_tokens) - 1, -1, -1):
            token = self.m_tokens[i]
            if token.Type() == "comment":
                if i > 0:
                    prev_token = self.m_tokens[i - 1]
                    if token.m_close_sequence == "\n" and prev_token.Type() == "raw" and not prev_token.m_code.endswith('\n'):
                        prev_token.m_code += '\n'
                self.m_tokens.pop(i)

    def MergeSpaces(self):
        for i in range(len(self.m_tokens) - 1, -1 + 1, -1):
            if self.m_tokens[i].Type() == "spaces" and self.m_tokens[i - 1].Type() == "spaces":
                self.m_tokens[i - 1].m_text += self.m_tokens[i].m_text
                self.m_tokens.pop(i)

    def MinifySpaces(self, remove_unused_new_lines):
        for i_token in range(len(self.m_tokens)):
            prev_token = (i_token > 0) and self.m_tokens[i_token - 1] or None
            token = self.m_tokens[i_token]
            next_token = (i_token < len(self.m_tokens) - 1) and self.m_tokens[i_token + 1] or None
            if token.Type() == "spaces":
                token.Minify(prev_token, next_token, remove_unused_new_lines)

    def ClearEmptyTokens(self):
        for i in range(len(self.m_tokens) - 1, -1, -1):
            token = self.m_tokens[i]
            if str(token) == "":
                self.m_tokens.pop(i)

    def IdentifierExists(self, name):
        for token in self.m_tokens:
            if token.Type() == "identifier":
                if str(token) == name:
                    return True
        return False

    def MinifyLocals(self):
        pass

    def MinifyStrings(self):
        strings = {}
        for token in self.m_tokens:
            if token.Type() == "string":
                s = str(token)
                if not s in strings:
                    strings[s] = 1
                else:
                    strings[s] += 1
        sorted_strings = sorted(strings.keys(), key=lambda k: -((len(k) - 2) * strings[k]))
        strs_names = ""
        strs_texts = ""
        s_number = 0
        for s in sorted_strings:
            s_count = strings[s]
            if (s_count >= 2 and (s_count * len(s) >= 6 + s_count)):
                s_number += 1
                for i_token in range(len(self.m_tokens)):
                    token = self.m_tokens[i_token]
                    if token.Type() == "string":
                        st = str(token)
                        if st == s:
                            self.m_tokens[i_token] = RawToken("_" + str(s_number))
                if strs_names != "":
                    strs_names += ","
                    strs_texts += ","
                strs_names += "_" + str(s_number)
                strs_texts += s
            if s_number >= self.m_minify_strings_local_count:
                break
        if strs_names != "":
            self.m_tokens.insert(0, RawToken("local " + strs_names + "=" + strs_texts))

    def Minify(self):
        if self.m_minify_locals:
            self.MinifyLocals()
        if self.m_minify_strings:
            self.MinifyStrings()
        if self.m_minify_comments:
            self.MinifyComments()
        self.MergeSpaces()
        if self.m_minify_spaces:
            self.MinifySpaces(self.m_minify_unreadable)
            self.ClearEmptyTokens()

    def GetSource(self):
        source = ""
        for token in self.m_tokens:
            str_token = str(token)
            source += str_token
        if not source.endswith('\n'):
            source += '\n'
        return source
    
    def GetTokenStrings(self):
        strs = []
        for token in self.m_tokens:
            strs.append(str(token))
        return strs



def Main(argc, argv):
    m = LUAMinifier()
    m.m_minify_comments = True
    m.m_minify_spaces = True
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
    m.LoadModule(source)
    m.Minify()
    print("minification done!")
    print("NEW SOURCE:")
    print(m.GetSource())
    print(GetTokenStringsWithTypes(m.m_tokens))



if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
