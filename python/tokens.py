LUA_SYMBOL_TOKENS = ["<=", ">=", "<", ">",  "==", "~=", "=", "[", "]", "(", ")", "{", "}", ";", "...", "..", ".", ":", ",", "+", "-", "*", "/", "^", "#", "%"]
LUA_WORD_OPERATORS = ["and", "or", "not"]
LUA_WORD_TOKENS = ["function", "while", "for", "do", "if", "elseif", "else", "then", "end", "local", "nil", "break", "repeat", "until", "true", "false", "in", "and", "or", "not", "return"]
LUA_NUM_CHARS = "bx0123456789abcdefABCDEF."
LUA_IDENTIFIER_FIRST_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"
LUA_IDENTIFIER_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_0123456789"



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
    """ Token representing a string. """

    def __init__(self, open_sequence, text, close_sequence):
        self.m_open_sequence = open_sequence
        self.m_text = text
        self.m_close_sequence = close_sequence
        if (open_sequence == "\"" or open_sequence == "\'") and text.find("\n") > -1:
            raise Exception("Syntax error: Unfinished string.")
    
    def Type(self):
        return "string"

    def __str__(self):
        return self.m_open_sequence + self.m_text + self.m_close_sequence



class CommentToken:
    """ Token representing a comment. """

    def __init__(self, open_sequence, text, close_sequence):
        self.m_open_sequence = open_sequence
        self.m_text = text
        self.m_close_sequence = close_sequence
    
    def Type(self):
        return "comment"

    def __str__(self):
        return self.m_open_sequence + self.m_text + self.m_close_sequence



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
            if len(str_prev) == 0 or len(str_next) == 0 or (str_prev[-1] in LUA_IDENTIFIER_CHARS and str_next[0] in LUA_IDENTIFIER_CHARS):
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
    """ Token representing a number. """
    
    def __init__(self, code):
        assert(len(code) > 0)
        self.m_code = code
    
    def Type(self):
        return "number"
    
    def __str__(self):
        return self.m_code



class WordToken:
    """ Token representing an identifier or keyword. """
    
    def __init__(self, code):
        assert(len(code) > 0)
        self.m_code = code
    
    def Type(self):
        if self.m_code in LUA_WORD_TOKENS:
            return "keyword"
        return "identifier"
    
    def __str__(self):
        return self.m_code



class OperatorToken:
    """ Token representing an operator. """
    
    def __init__(self, code):
        self.m_code = code
    
    def Type(self):
        return "operator"
    
    def __str__(self):
        return self.m_code



class RawToken:
    """ Token representing unparsed executable code. """
    
    def __init__(self, code):
        self.m_code = code
    
    def Type(self):
        return "raw"
    
    def __str__(self):
        return self.m_code



def GetTokenStringsWithTypes(tokens):
    strs = []
    for token in tokens:
        s = str(token) + "|" + token.Type()
        strs.append(s)
    return strs



def GetOperator(source, i):
    for op in LUA_SYMBOL_TOKENS:
        if source.find(op, i, i + len(op)) == i:
            return op
    for str_op in LUA_WORD_OPERATORS:
        if source.find(op, i, i + len(op)) == i and (len(source) - i <= len(str_op) or not IsIdentifierChar(source[i + len(str_op)])):
            return str_op
    return None



def GetTextToken(source, i):
    open_sequence = GetStringOpenSequence(source, i)
    if not open_sequence:
        return None, 0
    close_sequence = GetStringCloseSequence(open_sequence)
    i_close = -1
    i_close_search_start = i + len(open_sequence)
    while i_close == -1:
        i_close = source.find(close_sequence, i_close_search_start)
        if i_close == -1:
            raise Exception("Syntax error: Unfinished comment or string (opened with `{}`).".format(open_sequence))
        i_close_search_start = i_close + 1
        if ((open_sequence == "\"" or open_sequence == "'") and IsEscaped(source, i_close) == True):
            i_close = -1
    if open_sequence.startswith("--"):
        return CommentToken(open_sequence, source[i+len(open_sequence):i_close], close_sequence), i_close - i + len(close_sequence)
    else:
        return StringToken(open_sequence, source[i+len(open_sequence):i_close], close_sequence), i_close - i + len(close_sequence)
    


def GetSpaceToken(source, i):
    if not source[i].isspace():
        return None, 0
    i_end = i + 1
    while i_end < len(source) and source[i_end].isspace():
        i_end += 1
    return SpaceToken(source[i:i_end]), i_end - i



def GetNumberToken(source, i):
    if not source[i] in ".0123456789":
        return None, 0
    i_end = i + 1
    while i_end < len(source) and source[i_end] in LUA_NUM_CHARS:
        i_end += 1
    return NumberToken(source[i:i_end]), i_end - i



def GetOperatorToken(source, i):
    op = GetOperator(source, i)
    if op == None:
        return None, 0
    return OperatorToken(op), len(op)



def GetWordToken(source, i):
    if not source[i] in LUA_IDENTIFIER_FIRST_CHARS:
        return None, 0
    i_end = i + 1
    while i_end < len(source) and source[i_end] in LUA_IDENTIFIER_CHARS:
        i_end += 1
    return WordToken(source[i:i_end]), i_end - i



def GetAnyToken(source, i):
    token = None
    token_size = 0
    token, token_size = GetTextToken(source, i)
    if token != None:
        return token, token_size
    token, token_size = GetSpaceToken(source, i)
    if token != None:
        return token, token_size
    token, token_size = GetNumberToken(source, i)
    if token != None:
        return token, token_size
    token, token_size = GetOperatorToken(source, i)
    if token != None:
        return token, token_size
    token, token_size = GetWordToken(source, i)
    if token != None:
        return token, token_size
    raise Exception("Unknown token type.")



def Tokenize(source):
    tokens = []
    i = 1
    while i < len(source):
        token, token_size = GetAnyToken(source, i)
        if token == None:
            raise Exception("Unknown token type.")
        tokens.append(token)
        i += token_size
    return tokens
