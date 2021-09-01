@import Foundation;
@import ObjectiveC;

#define OBJ_POINTER $obj_pointer
#define NO_IVARS $no_ivars

id obj = (id) OBJ_POINTER;

NSMutableString *retstr = [NSMutableString string];

Class cls = object_getClass(obj);
if (!cls) {
    [retstr appendString:@"No class\n"];
} else {
    [retstr appendString:[NSString stringWithFormat:@"Class: %@\n", NSStringFromClass(cls)]];

    Class c = class_getSuperclass(cls);
    NSString *superClass;
    if (c) {
        superClass = [NSString stringWithFormat:@"Super class: %@\n", NSStringFromClass(c)];
    } else {
        superClass = @"No super class\n";
    }
    [retstr appendString:superClass];

#if !NO_IVARS

    // Visit https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100
    // to get all type encodings.
    #define GET_IVARS(TYPE) \
        { \
            [retstr appendString:@"\n" #TYPE " variables:\n"]; \
            unsigned int varCount = 0; \
            Ivar *vars = class_copyIvarList(cls, &varCount); \
            for (unsigned int i = 0; i < varCount; i++) { \
                Ivar var = vars[i]; \
                const char *typeEncodings = ivar_getTypeEncoding(var); \
                [retstr appendString:[NSString stringWithFormat:@"%s %s %ld", ivar_getName(var), typeEncodings, ivar_getOffset(var)]]; \
                if (strlen(typeEncodings) > 0) { \
                    if (!strcmp(typeEncodings, "@\"NSString\"")) { \
                        [retstr appendString:[NSString stringWithFormat:@" : %@", object_getIvar(obj, var)]]; \
                    } else if (typeEncodings[0] == '@') { \
                        [retstr appendString:[NSString stringWithFormat:@" : %p", object_getIvar(obj, var)]]; \
                    } \
                } \
                [retstr appendString:@"\n"]; \
            } \
            free(vars); \
        }

    GET_IVARS(Instance)
#endif
}

retstr;
