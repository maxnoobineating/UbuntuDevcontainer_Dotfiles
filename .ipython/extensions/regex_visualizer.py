import re

def reviz(line):
    assert len(args:=list(filter(lambda s: s!='', line.split(' ')))) == 2, TypeError('reviz takes 2 arguments: (pattern, string)')
    pattern_name, string_name = args
    pattern = get_ipython().ev(pattern_name)
    string = get_ipython().ev(string_name)
    charlist = list(string)
    regiter = re.finditer(pattern, string)
    deviate = 0
    for m in regiter:
        print(m)
        begin, end = m.span()
        charlist.insert(begin+deviate, '\033[91m')
        charlist.insert(end+deviate+1, '\033[0m')
        # charlist.insert(begin+deviate, r'[')
        # charlist.insert(end+deviate, r']')
        deviate += 2
    print(''.join(charlist))

def load_ipython_extension(ipython):
    """This function is called when the extension is
    loaded. It accepts an IPython InteractiveShell
    instance. We can register the magic with the
    `register_magic_function` method of the shell
    instance."""
    ipython.register_magic_function(reviz)
