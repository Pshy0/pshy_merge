#!/usr/bin/python3
import sys
import re



LUA_SYMBOL_TOKENS = ["<=", ">=", "<", ">",  "==", "~=", "=", "[", "]", "(", ")", "{", "}", ";", "...", "..", ".", ":", ",", "+", "-", "*", "/", "^", "#", "%"]
LUA_WORD_OPERATORS = ["and", "or", "not"]
LUA_WORD_TOKENS = ["function", "while", "for", "do", "if", "elseif", "else", "then", "end", "local", "nil", "break", "repeat", "until", "true", "false", "in", "and", "or", "not", "return"]


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



def IsNumberChar(c):
    return c in "bx0123456789abcdefABCDEF."



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



class RawToken:
    """ Code Token representing executable code with no text or comment. """
    
    def __init__(self, code):
        self.m_code = code
    
    def Type(self):
        return "raw"
    
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



class NumberToken:
    """ Code Token representing a number. """
    
    def __init__(self, code):
        assert(len(code) > 0)
        self.m_code = code
    
    def Type(self):
        return "number"
    
    def __str__(self):
        return self.m_code



class WordToken:
    """ Code Token representing an identifier or keyword. """
    
    def __init__(self, code):
        assert(len(code) > 0)
        self.m_code = code
        self.m_is_member = False
        self.m_is_local = False
        self.m_local_level = None
    
    def Type(self):
        if self.m_code in LUA_WORD_TOKENS:
            return "keyword"
        return "identifier"
    
    def __str__(self):
        return self.m_code



class OperatorToken:
    """ Code Token representing an operator. """
    
    def __init__(self, code):
        self.m_code = code
    
    def Type(self):
        return "operator"
    
    def __str__(self):
        return self.m_code



    
def GetTokenStringsWithTypes(tokens):
    strs = []
    for token in tokens:
        s = str(token) + "|" + token.Type()
        if token.Type() == "identifier" and token.m_is_local:
            s += "(local{})".format(token.m_scope_index)
        strs.append(s)
    return strs



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
                tokens.append(RawToken(source[i_after_last_sequence : i_open]))
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
        tokens.append(RawToken(source[i_after_last_sequence : i]))
    return tokens



def TokenizeSpaces(tokens):
    new_tokens = []
    for token in tokens:
        if token.Type() == "raw":
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
                        new_tokens.append(RawToken(cur_text))
                    if i < len(text):
                        cur_text = text[i]
                        cur_is_space = text[i].isspace()
        else:
            new_tokens.append(token) 
    return new_tokens



def TokenizeNumbers(tokens):
    new_tokens = []
    for token in tokens:
        if token.Type() == "raw":
            text = token.m_code
            cur_is_number = (text[0] in "0123456789.")
            cur_text = ""
            for i in range(len(text) + 1):
                is_number = cur_is_number
                if i < len(text) and i > 0 and not cur_is_number:
                    is_number = ((text[i] in "0123456789.") and not IsIdentifierChar(text[i - 1]))
                if i < len(text) and i > 0 and cur_is_number:
                    is_number = IsNumberChar(text[i])
                if i < len(text) and cur_is_number == is_number:
                    cur_text += text[i]
                else:
                    if cur_is_number:
                        new_tokens.append(NumberToken(cur_text))
                    else:
                        new_tokens.append(RawToken(cur_text))
                    if i < len(text):
                        cur_text = text[i]
                        cur_is_number = (text[i] in "0123456789.")
        else:
            new_tokens.append(token)
    #print(GetTokenStringsWithTypes(new_tokens))
    return new_tokens



def GetOperator(source, i):
    for op in LUA_SYMBOL_TOKENS:
        if source.find(op, i, i + len(op)) == i:
            return op
    for str_op in LUA_WORD_OPERATORS:
        if source.find(op, i, i + len(op)) == i and (len(source) - i <= len(str_op) or not IsIdentifierChar(source[i + len(str_op)])):
            return str_op
    return None



def TokenizeOperators(tokens):
    new_tokens = []
    for token in tokens:
        if token.Type() == "raw":
            text = token.m_code
            non_op_text = ""
            i = 0
            while i < len(text):
                op = GetOperator(text, i)
                if not op:
                    non_op_text += text[i]
                    i += 1
                else:
                    if len(non_op_text) > 0:
                        new_tokens.append(RawToken(non_op_text))
                        non_op_text = ""
                    new_tokens.append(OperatorToken(op))
                    i += len(op)
            if len(non_op_text) > 0:
                new_tokens.append(RawToken(non_op_text))
                non_op_text = ""
        else:
            new_tokens.append(token) 
    return new_tokens



def TokenizeWords(tokens):
    new_tokens = []
    for token in tokens:
        if token.Type() == "raw":
            text = token.m_code
            for c in text:
                if not IsIdentifierChar(c):
                    raise Exception(token)
            new_tokens.append(WordToken(text))
        else:
            new_tokens.append(token) 
    return new_tokens



def TokenizationComputeScopes(tokens):
    # TODO: this is an experiment
    expect_dothen = False
    accept_funcname = False
    scope_index = 0
    high_scope_index = 0
    scope_level = 0
    scopes = []
    for token in tokens:
        #print("SCOPE " + str(scope_level) + ":" + str(token))
        #print("EXPECT DOTHEN: " + str(expect_dothen))
        if token.Type() == "spaces":
            continue
        elif token.Type() == "identifier":
            if accept_funcname:
                token.m_scope_level = scope_level - 1
                token.m_scope_index = scopes[-1]
            else:
                token.m_scope_level = scope_level
                token.m_scope_index = scope_index
            #print("IDENTIFIER")
        else:
            scope_mod = 0
            if not str(token) in ".:":
                accept_funcname = False
            if str(token) in ["if", "while", "for"]:
                scope_mod = 1
                expect_dothen = True
            elif str(token) in ["repeat", "function"]:
                scope_mod = 1
                if str(token) == "function":
                    accept_funcname = True
            elif str(token) in ["do", "then"]:
                if not expect_dothen:
                    scope_mod = 1
                else:
                    expect_dothen = False
            elif str(token) in ["end", "until"]:
                scope_mod = -1
            elif str(token) in ["else", "elseif"]:
                high_scope_index += 1
                scope_index = high_scope_index
            if scope_mod == 1:
                scope_level += 1
                scopes.append(scope_index)
                high_scope_index += 1
                scope_index = high_scope_index
            elif scope_mod == -1:
                scope_level -= 1
                scope_index = scopes.pop()



def Tokenize(source):
    tokens = TokenizeTexts(source)
    tokens = TokenizeSpaces(tokens)
    tokens = TokenizeNumbers(tokens)
    tokens = TokenizeOperators(tokens)
    tokens = TokenizeWords(tokens)
    TokenizationComputeScopes(tokens)
    # finalize
    were_member_access_op = False
    local_def = False
    local_just_def = False
    for token in tokens:
        if token.Type() == "comment" or token.Type() == "spaces":
            continue
        elif token.Type() == "raw":
            raise Exception("Invalid token `{}`.".format(str(token)))
        elif token.Type() == "operator":
            assert(were_member_access_op == False)
            if str(token) in ".:":
                were_member_access_op = True
            if str(token) == "," and local_just_def:
                local_def = True
                local_just_def = False
            if str(token) in "=;":
                local_just_def = False
        elif str(token) == "local" or str(token) == "for":
            assert(were_member_access_op == False)
            assert(local_def == False)
            local_def = True
            local_just_def = False
        elif token.Type() == "number":
            assert(were_member_access_op == False)
            assert(local_def == False)
            local_just_def = False
        elif token.Type() == "keyword":
            assert(were_member_access_op == False)
            if str(token) != "function":
                local_def = False
            local_just_def = False
        elif token.Type() == "identifier":
            if were_member_access_op:
                token.m_is_member = True
                were_member_access_op = False
            elif local_def and token.Type() != "keyword":
                assert(token.Type() != "number")
                token.m_is_local = True
                local_def = False
                local_just_def = True
            else:
                local_just_def = False
    return tokens



def NextCombination(identifier):
    IDCHARS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    if identifier == None:
        return 'a'
    else:
        identifier = list(identifier)
        i_c = 0
        while True:
            if i_c >= len(identifier):
                identifier += IDCHARS[0]
                return ''.join(identifier)
            else:
                c = identifier[i_c]
                if c == IDCHARS[-1]:
                    identifier[i_c] = IDCHARS[0]
                    i_c += 1
                else:
                    i_idchar = IDCHARS.find(c)
                    identifier[i_c] = IDCHARS[i_idchar + 1]
                    return ''.join(identifier)



def NextName(identifier):
    identifier = NextCombination(identifier)
    while identifier in LUA_WORD_TOKENS:
        identifier = NextCombination(identifier)
    return identifier


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
        local_names = {}
        for token in self.m_tokens:
            if token.Type() == "identifier" and token.m_is_local and len(str(token)) > 2:
                if not str(token) in local_names or token.m_scope_level < local_names[str(token)][0]:
                    local_names[str(token)] = (token.m_scope_level, token.m_scope_index)
        for token in self.m_tokens:
            if token.Type() == "identifier":
                for local_name in local_names:
                    if local_name == str(token):
                        if token.m_is_member or token.m_scope_level < local_names[local_name][0] or (token.m_scope_level == local_names[local_name][0] and token.m_scope_index != local_names[local_name][1]):
                            local_names.pop(local_name)
                            break
        idname = None
        new_local_names = {}
        for local_name in local_names:
            idname = NextName(idname)
            while self.IdentifierExists(idname):
                idname = NextName(idname)
            new_local_names[local_name] = idname
        #print("-- LOCALS: " + str(new_local_names), file=sys.stderr)
        for token in self.m_tokens:
            if token.Type() == "identifier":
                if str(token) in new_local_names:
                    token.m_code = new_local_names[str(token)]

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
    m.m_minify_locals = True
    source = r"""
local variable_nana = {}
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
