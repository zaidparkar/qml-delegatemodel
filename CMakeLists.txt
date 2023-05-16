cmake_minimum_required(VERSION 3.16)

project(contactsPicker VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick)

qt_standard_project_setup()

qt_add_executable(appcontactsPicker
    main.cpp
    modelclass.h
    modelclass.cpp
    contactClass.cpp
)

qt_add_qml_module(appcontactsPicker
    URI contactsPicker
    VERSION 1.0
    QML_FILES Main.qml
)

set_target_properties(appcontactsPicker PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

qt_add_resources(appcontactsPicker "android"
PREFIX /
FILES
android/AndroidManifest.xml
android/build.gradle
android/src/com/example/contactsPicker/MainActivity.java
)

target_link_libraries(appcontactsPicker
    PRIVATE Qt6::Quick
)

install(TARGETS appcontactsPicker
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
