import lldb
from lldb_extra import utils

def dump_obj(obj_pointer, no_ivars = False):
    '''The `obj_pointer` can be a memory address, or an expression which
    returns a pointer to an object.
    '''
    opts = { 'obj_pointer': obj_pointer, 'no_ivars': 1 if no_ivars else 0 }
    return utils.render_script_and_evaluate('dump_obj.mm', opts)
