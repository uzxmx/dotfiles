def get_registers(frame, kind):
    '''Returns the registers given the frame and the kind of registers desired.

    Returns None if there's no such kind.
    '''
    registerSet = frame.GetRegisters() # Return type of SBValueList.
    for value in registerSet:
        if kind.lower() in value.GetName().lower():
            return { r.GetName(): r for r in value }

    return None

def get_GPRs(frame):
    '''Returns the general purpose registers of the frame as a dict.
    '''
    return get_registers(frame, 'general purpose')

def get_FPRs(frame):
    '''Returns the floating point registers of the frame as a dict.
    '''
    return get_registers(frame, 'floating point')

def get_ESRs(frame):
    '''Returns the exception state registers of the frame as a dict.
    '''
    return get_registers(frame, 'exception state')

def resume_execution(frame):
    '''Resumes the execution.
    '''
    frame.GetThread().GetProcess().Continue()
