import os
import re
import subprocess
import sys



def ReadFile(file_name):
    f = open(file_name, mode="r")
    content = f.read()
    f.close()
    return content



def WriteFile(file_name, content):
    f = open(file_name, mode="w")
    f.write(content)
    f.close()



def ListLineRequires(line, vanilla_require):
    requires = []
    require_regex = r"(--)|\bpshy\.require\s*\(\s*\"(.*?)\"\s*\)|\bpshy\.require\s*\(\s*\'(.*?)\'\s*\)|\bpshy\.require\s*\(\s*\[\[(.*?)\]\]\s*\)|\bpshy\.require\s*\"(.*?)\""
    if vanilla_require:
        require_regex = r"(--)|\brequire\s*\(\s*\"(.*?)\"\s*\)|\brequire\s*\(\s*\'(.*?)\'\s*\)|\brequire\s*\(\s*\[\[(.*?)\]\]\s*\)|\brequire\s*\"(.*?)\""
    matches = re.findall(require_regex, line)
    for match in matches:
        for match_group in match:
            if match_group == '--':
                return requires 
            if match_group != '':
                requires.append(match_group)
    return requires



def ListRequires(code, vanilla_require):
    requires = []
    for line in code.splitlines():
        requires.extend(ListLineRequires(line, vanilla_require))
    return requires



def GetCommitsSinceTag(directory, tag):
    p = subprocess.Popen(["git rev-list " + tag + "..HEAD --count"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8", cwd = directory)
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return int(output.strip(" \t\r\n"))



def GetCommitCountStr(directory):
    p = subprocess.Popen(["git rev-list HEAD --count"], stdout = subprocess.PIPE, shell = True, encoding = "utf-8", cwd = directory)
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return int(output.strip(" \t\r\n"))



def GetLatestGitTag(directory, minus = 0):
    command = "git describe --tags --abbrev=0 HEAD~" + str(minus)
    p = subprocess.Popen([command], stdout = subprocess.PIPE, shell = True, encoding = "utf-8", cwd = directory)
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    return output.strip(" \t\r\n")
    
    

def GetLatestGitVersionTag(directory, minus = 0):
    latest_tag = GetLatestGitTag(directory, minus)
    command = "git tag --points-at " + latest_tag
    p = subprocess.Popen([command], stdout = subprocess.PIPE, shell = True, encoding = "utf-8", cwd = directory)
    (output, err) = p.communicate()
    p_status = p.wait()
    if p_status != 0:
        raise Exception(err)
    tags = output.strip(" \t\r\n").split('\n')
    for tag in tags:
        if re.match("v[0-9].*", tag):
            return tag
    commits_since_tag = GetCommitsSinceTag(directory, tag)
    return GetLatestGitVersionTag(directory, commits_since_tag + 1)



def GetVersion(directory):
    try:
        tag = GetLatestGitVersionTag(directory)
        build = GetCommitsSinceTag(directory, tag)
        if build == 0:
            return tag
        else:
            return tag + "+" + str(build)
    except:
        try:
            commit_count = GetCommitCountStr(directory)
            print("-- WARNING: No git version tag, cannot determine script's version.", file=sys.stderr)
            return "v0+" + str(commit_count)
        except:
            return "v0-notgit"



def InsertBeforeReturn(source, addition):
    lines = source.rstrip('\n').split('\n')
    i_insert = -1
    for i in range(len(lines) - 1,-1,-1):
        if lines[i].startswith("return "):
            if i_insert != -1:
                return source
            i_insert = i
            break
        if (not lines[i] == "") and (not lines[i] == "}") and (not lines[i].startswith(" ")) and (not lines[i].startswith('\t')):
            i_insert = len(lines)
    if i_insert == -1:
        print("-- WARNING: Norm error (indentation), cannot insert source footer.", file=sys.stderr)
        return source
    lines.insert(i_insert, addition.strip('\n'))
    return "\n".join(lines)



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
