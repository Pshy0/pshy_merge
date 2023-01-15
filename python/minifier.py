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
    


def PrintChunks(chunks):
    for chunk in chunks:
        print("<-> " + str(chunk))



def IsIdentifierChar(c):
    return c.isalnum() or (c == "_")



class StringChunk:
    """ Code Chunk representing some text or comment. """

    def __init__(self, open_sequence, text, close_sequence):
        self.m_open_sequence = open_sequence
        self.m_text = text
        self.m_close_sequence = close_sequence
        self.m_is_comment = False
        if open_sequence.startswith("--"):
            self.m_is_comment = True
        if (open_sequence == "\"" or open_sequence == "\'") and text.find("\n") > -1:
            raise Exception("Syntax error: Unfinished comment or string.")

    def __str__(self):
        return self.m_open_sequence + self.m_text + self.m_close_sequence
        #return ((self.m_is_comment and "cmt:" or "str:") + "<" + self.m_open_sequence + ">" + self.m_text + "<" + self.m_close_sequence + ">").replace("\n", "\\n")



class CodeChunk:
    """ Code Chunk representing executable code with no text or comment. """
    
    def __init__(self, code):
        self.m_code = code
    
    def MinifySpaces(self):
        #had_line_feed = self.m_code[-1] == "\n"
        #self.m_code = re.sub(r'\t*$', '', self.m_code, flags=re.MULTILINE)
        #self.m_code = re.sub(r'^\t*', '', self.m_code, flags=re.MULTILINE)
        #self.m_code = re.sub(r' *$', '', self.m_code, flags=re.MULTILINE)
        #self.m_code = re.sub(r'^ *', '', self.m_code, flags=re.MULTILINE)
        #if had_line_feed:
        #    self.m_code += "\n"
        self.m_code = self.m_code.replace("\t", " ")
        parts = self.m_code.split(" ")
        for i in range(len(parts) - 1,-1,-1):
            if parts[i] == "":
                parts.pop(i)
        for i in range(0, len(parts) - 1):
            if IsIdentifierChar(parts[i][-1]) and IsIdentifierChar(parts[i + 1][0]):
                parts[i] += " "
        self.m_code = "".join(parts)
        while(self.m_code.find("\n\n") >= 0):
            self.m_code = self.m_code.replace("\n\n", "\n")

    def MinifyUnreadable(self):
        parts = self.m_code.split('\n')
        for i in range(len(parts) - 1,-1,-1):
            if parts[i] == "":
                parts.pop(i)
        for i in range(0, len(parts) - 1):
            if IsIdentifierChar(parts[i][-1]) and IsIdentifierChar(parts[i + 1][0]):
                parts[i] += " "
        self.m_code = "".join(parts)
    
    def __str__(self):
        return self.m_code



class LUAMinifier:

    def __init__(self):
        self.m_chunks = []
        self.m_minify_comments = False
        self.m_minify_spaces = False
        self.m_minify_unreadable = False
        self.m_minify_strings = False
        self.m_obfuscate = False

    def LoadModule(self, source):
        chunks = []
        chunk_start = 0
        i_after_last_sequence = 0
        i = 0
        while i < len(source):
            open_sequence = GetStringOpenSequence(source, i)
            if open_sequence != None:
                i_open = i
                if i_after_last_sequence != i_open:
                    chunks.append(CodeChunk(source[i_after_last_sequence : i_open]))
                close_sequence = GetStringCloseSequence(open_sequence)
                i_close = -1
                i = i_open + len(open_sequence)
                while (i_close < 0) or ((open_sequence == "\"" or open_sequence == "'") and IsEscaped(source, i_close) == True):
                    i_close = source.find(close_sequence, i)
                    if i_close == -1:
                        raise Exception("Syntax error: Unfinished comment or string.")
                    i = i_close + 1
                assert(i_close >= 0)
                c = StringChunk(open_sequence, source[i_open + len(open_sequence) : i_close], close_sequence)
                chunks.append(c)
                i = i_close + len(close_sequence)
                i_after_last_sequence = i
            else:
                i += 1
        if i_after_last_sequence != i:
            chunks.append(CodeChunk(source[i_after_last_sequence : i]))
        self.m_chunks = chunks
    
    def MinifyComments(self):
        for i in range(len(self.m_chunks) - 1, -1, -1):
            chunk = self.m_chunks[i]
            if (type(chunk) is StringChunk):
                if chunk.m_is_comment:
                    if i > 0:
                        prev_chunk = self.m_chunks[i - 1]
                        if chunk.m_close_sequence == "\n" and (type(prev_chunk) is CodeChunk) and not prev_chunk.m_code.endswith('\n'):
                            prev_chunk.m_code += '\n'
                    self.m_chunks.pop(i)
                    
    def MinifySpaces(self):
        for chunk in self.m_chunks:
            if type(chunk) == CodeChunk:
                chunk.MinifySpaces()
    
    def MinifyEmptyCodes(self):
        for i in range(len(self.m_chunks) - 1, -1, -1):
            chunk = self.m_chunks[i]
            if (type(chunk) is CodeChunk):
                if chunk.m_code.strip("\n \t") == "":
                    self.m_chunks.pop(i)
        for i in range(0, len(self.m_chunks) - 1):
            if (type(self.m_chunks[i]) is CodeChunk and type(self.m_chunks[i + 1]) is CodeChunk):
                if self.m_chunks[i].m_code[-1] == '\n' and self.m_chunks[i + 1].m_code[0] == '\n':
                    self.m_chunks[i + 1].m_code = self.m_chunks[i + 1].m_code[1:]
    
    def MinifyUnreadable(self):
        for chunk in self.m_chunks:
            if type(chunk) == CodeChunk:
                chunk.MinifyUnreadable()
    
    def Minify(self):
        if self.m_minify_comments:
            self.MinifyComments()
        if self.m_minify_spaces:
            self.MinifySpaces()
            self.MinifyEmptyCodes()
        if self.m_minify_unreadable:
            self.MinifyUnreadable()
        if self.m_minify_strings:
            pass
    
    def GetSource(self):
        source = ""
        for chunk in self.m_chunks:
            str_chunk = str(chunk)
            if len(source) > 0 and IsIdentifierChar(source[len(source) - 1]) and IsIdentifierChar(str_chunk[0]):
                source += (self.m_obfuscate and " " or "\n")
            source += str_chunk
        if not source.endswith('\n'):
        	source += '\n'
        return source
            


def Main(argc, argv):
    m = LUAMinifier()
    m.m_minify_comments = True
    source = r"""
--- This is some module code
-- it's not important
function f()
    a  =  5 -- why do i do that
	b  =  "because\" i can"
	 c  =  [[am i sure about that]]
    print(tostring(a) .. b ..  c)
    "
end
--[[ multiline
 comment to
serve you]]
 f()
return false
"""
    m.LoadModule(source)
    m.Minify()
    print("NEW SOURCE:")
    print(m.GetSource())



if __name__ == "__main__":
    Main(len(sys.argv), sys.argv)
