@import Foundation;
@import ObjectiveC;

#define CLASS_NAME "$class_name"

NSMutableString *retstr = [NSMutableString string];

Class cls = objc_getClass(CLASS_NAME);
unsigned int methodCount = 0;
Method *methods = class_copyMethodList(cls, &methodCount);

Class c = class_getSuperclass(cls);
NSString *superClass;
if (c) {
    superClass = [NSString stringWithFormat:@"Super class: %@\n\n", NSStringFromClass(c)];
} else {
    superClass = @"No super class\n\n";
}
[retstr appendString:superClass];

for (unsigned int i = 0; i < methodCount; i++) {
    Method method = methods[i];
    NSString *methodName = [NSString stringWithFormat:@"[%p] -[%@ %@]\n", method_getImplementation(method), NSStringFromClass(cls), NSStringFromSelector(method_getName(method))];
    [retstr appendString:methodName];
}

free(methods);
retstr;
