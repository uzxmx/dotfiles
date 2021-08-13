@import Foundation;
@import ObjectiveC;

NSMutableString *retstr = [NSMutableString string];

int classCount = objc_getClassList(NULL, 0);
Class *classes = (__unsafe_unretained Class *) malloc(sizeof(Class) * classCount);
objc_getClassList(classes, classCount);
for (int i = 0; i < classCount; i++) {
    Class cls = classes[i];
    [retstr appendString:[NSString stringWithFormat:@"%@\n", NSStringFromClass(cls)]];
}
free(classes);

retstr;
