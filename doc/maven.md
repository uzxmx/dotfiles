## Commands

```
# https://github.com/LearnLib/learnlib/wiki/Setting-Up-a-New-Maven-Project-(Command-Line)
# https://www.vogella.com/tutorials/ApacheMaven/article.html
mvn archetype:generate

# https://stackoverflow.com/questions/1089285/maven-run-project
mvn exec:java -Dexec.mainClass=foo.App
mvn test
mvn -Dtest=com.example.Test test
mvn -Dtest=com.example.Test#foo test

mvn install -DskipTests
# Use `maven.test.skip` property to skip compiling the tests
mvn install -Dmaven.test.skip=true
```

## Show help

```
mvn help:help -Ddetail=true
mvn help:describe
mvn help:describe -Dcmd=spring-boot:run -Ddetail
mvn help:describe -Dplugin=org.jacoco:jacoco-maven-plugin -Ddetail
```

## Redirect output to file when using surefire to test

```
# Output will be saved in PROJECT_ROOT/target/surefire-reports/xxx-output.txt
mvn test -Dmaven.test.redirectTestOutputToFile=true
```
