@import Foundation;
@import ObjectiveC;

#define PARENT_CLASS_NAME "$parent_class_name"
#define FILTER_BY_PARENT_CLASS $filter_by_parent_class

NSMutableString *retstr = [NSMutableString string];

#if FILTER_BY_PARENT_CLASS
Class parentClass = objc_getClass(PARENT_CLASS_NAME);
#endif

int classCount = objc_getClassList(NULL, 0);
Class *classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * classCount);
objc_getClassList(classes, classCount);
for (int i = 0; i < classCount; i++) {
    Class cls = classes[i];

    #if FILTER_BY_PARENT_CLASS
    bool isSubclass = false;
    Class currentClass = class_getSuperclass(cls);
    while (currentClass) {
      if (currentClass == parentClass) {
        isSubclass = true;
        break;
      }
      currentClass = class_getSuperclass(currentClass);
    }
    if (!isSubclass) {
      continue;
    }
    #endif

    [retstr appendString:[NSString stringWithFormat:@"%@\n", NSStringFromClass(cls)]];
}
free(classes);

retstr;
