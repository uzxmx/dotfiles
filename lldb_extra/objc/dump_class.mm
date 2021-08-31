@import Foundation;
@import ObjectiveC;

#define CLASS_NAME "$class_name"
#define ENABLE_CLASS $enable_class

NSMutableString *retstr = [NSMutableString string];

Class cls = objc_getClass(CLASS_NAME);

Class c = class_getSuperclass(cls);
NSString *superClass;
if (c) {
    superClass = [NSString stringWithFormat:@"Super class: %@\n", NSStringFromClass(c)];
} else {
    superClass = @"No super class\n";
}
[retstr appendString:superClass];

#define GET_IVARS(TYPE) \
    { \
        [retstr appendString:@"\n" #TYPE " variables:\n"]; \
        unsigned int varCount = 0; \
        Ivar *vars = class_copyIvarList(cls, &varCount); \
        for (unsigned int i = 0; i < varCount; i++) { \
            Ivar var = vars[i]; \
            NSString *varName = [NSString stringWithFormat:@"%s %s %d\n", ivar_getName(var), ivar_getTypeEncoding(var), ivar_getOffset(var)]; \
            [retstr appendString:varName]; \
        } \
        free(vars); \
    }

#define GET_METHODS(TYPE, SIGN) \
    { \
        [retstr appendString:@"\n" #TYPE " methods:\n"]; \
        unsigned int methodCount = 0; \
        Method *methods = class_copyMethodList(cls, &methodCount); \
        for (unsigned int i = 0; i < methodCount; i++) { \
            Method method = methods[i]; \
            NSString *methodName = [NSString stringWithFormat:@"[%p] " #SIGN "[%@ %@]\n", method_getImplementation(method), NSStringFromClass(cls), NSStringFromSelector(method_getName(method))]; \
            [retstr appendString:methodName]; \
        } \
        free(methods); \
    }

GET_IVARS(Instance)
GET_METHODS(Instance, -)

#if ENABLE_CLASS
cls = object_getClass(cls);
GET_IVARS(Class)
GET_METHODS(Class, +)
#endif

retstr;
