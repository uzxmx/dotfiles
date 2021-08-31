import lldb
from lldb_extra import utils

def dump_obj(obj_pointer):
    opts = { 'obj_pointer': obj_pointer }
    return utils.render_script_and_evaluate('dump_obj.mm', opts)
