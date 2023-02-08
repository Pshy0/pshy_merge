#!/usr/bin/python3
import sys
import re



def GetStringOpenSequence(source, index):
    if source[index] == "\"":
        return "\""
    if source[index] == "\'":
        return "\'"
    if source[index] == "[":
        full_sequence = "["
        i = index + 1
        while source[i] == "=":
            full_sequence += "="
            i += 1
        if source[i] == "[":
            return full_sequence + "["
    if source[index:index+3] == "--[":
        full_sequence = "--["
        i = index + 3
        while source[i] == "=":
            full_sequence += "="
            i += 1
        if source[i] == "[":
            return full_sequence + "["
    if source[index:index+1+1] == "--":
        return "--"
    return None



def IsEscaped(source, index):
    #assert((source[index] == "\"" or source[index] == "'"))
    if index == 0:
        return False
    while source[index - 1] == '\\':
        if source[index - 2] != '\\':
            return True
        index -= 2
    return False



def GetStringCloseSequence(open_sequence):
    if open_sequence == "--":
        return "\n"
    elif open_sequence.startswith("--["):
        open_sequence = open_sequence[2:] 
    return open_sequence.replace("[", "]")
    


def PrintTokens(tokens):
    for token in tokens:
        print("<-> " + str(token))



def IsIdentifierChar(c):
    return c.isalnum() or (c == "_")



class StringToken:
    """ Code Token representing some text or comment. """

    def __init__(self, open_sequence, text, close_sequence):
        self.m_open_sequence = open_sequence
        self.m_text = text
        self.m_close_sequence = close_sequence
        self.m_is_comment = False
        if open_sequence.startswith("--"):
            self.m_is_comment = True
        if (open_sequence == "\"" or open_sequence == "\'") and text.find("\n") > -1:
            raise Exception("Syntax error: Unfinished comment or string.")
    
    def Type(self):
        if self.m_is_comment:
            return "comment"
        else:
            return "string"

    def __str__(self):
        return self.m_open_sequence + self.m_text + self.m_close_sequence
        #return ((self.m_is_comment and "cmt:" or "str:") + "<" + self.m_open_sequence + ">" + self.m_text + "<" + self.m_close_sequence + ">").replace("\n", "\\n")



class CodeToken:
    """ Code Token representing executable code with no text or comment. """
    
    def __init__(self, code):
        self.m_code = code
    
    def Type(self):
        return "code"
    
    def __str__(self):
        return self.m_code



class SpaceToken:
    """ Token representing meaningless spacing characters. """
    
    def __init__(self, text):
        self.m_text = text
    
    def Minify(self, prev_token, next_token, remove_uneeded_new_lines):
        if not remove_uneeded_new_lines and "\n" in self.m_text:
            self.m_text = "\n"
        elif prev_token == None or next_token == None:
            self.m_text = ""
        else:
            str_prev = str(prev_token)
            str_next = str(next_token)
            if len(str_prev) == 0 or len(str_next) == 0 or (IsIdentifierChar(str_prev[-1]) and IsIdentifierChar(str_next[0])):
                if "\n" in self.m_text:
                    self.m_text = "\n"
                else:
                    self.m_text = " "
            else:
                self.m_text = ""
    
    def Type(self):
        return "spaces"
    
    def __str__(self):
        return self.m_text



def TokenizeTexts(source):
    tokens = []
    token_start = 0
    i_after_last_sequence = 0
    i = 0
    while i < len(source):
        open_sequence = GetStringOpenSequence(source, i)
        if open_sequence != None:
            i_open = i
            if i_after_last_sequence != i_open:
                tokens.append(CodeToken(source[i_after_last_sequence : i_open]))
            close_sequence = GetStringCloseSequence(open_sequence)
            i_close = -1
            i = i_open + len(open_sequence)
            while (i_close < 0) or ((open_sequence == "\"" or open_sequence == "'") and IsEscaped(source, i_close) == True):
                i_close = source.find(close_sequence, i)
                if i_close == -1:
                    raise Exception("Syntax error: Unfinished comment or string (opened with `{}`).".format(open_sequence))
                i = i_close + 1
            assert(i_close >= 0)
            c = StringToken(open_sequence, source[i_open + len(open_sequence) : i_close], close_sequence)
            tokens.append(c)
            i = i_close + len(close_sequence)
            i_after_last_sequence = i
        else:
            i += 1
    if i_after_last_sequence != i:
        tokens.append(CodeToken(source[i_after_last_sequence : i]))
    return tokens



def TokenizeSpaces(tokens):
    new_tokens = []
    for token in tokens:
        if token.Type() == "code":
            text = token.m_code
            cur_is_space = text[0].isspace()
            cur_text = ""
            for i in range(len(text) + 1):
                if i < len(text) and text[i].isspace() == cur_is_space:
                    cur_text += text[i]
                else:
                    if cur_is_space:
                        new_tokens.append(SpaceToken(cur_text))
                    else:
                        new_tokens.append(CodeToken(cur_text))
                    if i < len(text):
                        cur_text = text[i]
                        cur_is_space = text[i].isspace()
        else:
            new_tokens.append(token) 
    return new_tokens
    


def Tokenize(source):
    tokens = TokenizeTexts(source)
    tokens = TokenizeSpaces(tokens)
    return tokens



class LUAMinifier:

    def __init__(self):
        self.m_tokens = []
        self.m_minify_comments = False
        self.m_minify_spaces = False
        self.m_minify_unreadable = False
        self.m_minify_strings = False
        self.m_minify_strings_local_count = 120
        self.m_obfuscate = False

    def LoadModule(self, source):
        self.m_tokens = Tokenize(source)

    def MinifyComments(self):
        for i in range(len(self.m_tokens) - 1, -1, -1):
            token = self.m_tokens[i]
            if token.Type() == "comment":
                if i > 0:
                    prev_token = self.m_tokens[i - 1]
                    if token.m_close_sequence == "\n" and prev_token.Type() == "code" and not prev_token.m_code.endswith('\n'):
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
                            self.m_tokens[i_token] = CodeToken("_" + str(s_number))
                if strs_names != "":
                    strs_names += ","
                    strs_texts += ","
                strs_names += "_" + str(s_number)
                strs_texts += s
            if s_number >= self.m_minify_strings_local_count:
                break
        if strs_names != "":
            self.m_tokens.insert(0, CodeToken("local " + strs_names + "=" + strs_texts)) #181666

    def Minify(self):
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



def Main(argc, argv):
    m = LUAMinifier()
    m.m_minify_comments = True
    m.m_minify_spaces = True
    source = r"""
local n
--- This is some module code
-- it's not important
function f()
    a  =  5 -- why do i do that
	b  =  "because\" i can"
	 c  =  [[am i sure about that]]
    print(tostring(a) .. b ..  c)
end
--[[ multiline
 comment to
serve you]]
 f()
return false
"""
    m.LoadModule(source)
    m.Minify()
    print("minification done!")
    print("NEW SOURCE:")
    print(m.GetSource())



if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
