@echo off 
set OutDebugFile=output\koExternalTemplateEngine.debug.js
set OutMinFile=output\koExternalTemplateEngine.js
set AllFiles=
for /f "eol=] skip=1 delims=' " %%i in (source-references.js) do set Filename=%%i& call :Concatenate 

goto :Combine
:Concatenate 
    if /i "%AllFiles%"=="" ( 
        set AllFiles=..\%Filename:/=\%
    ) else ( 
        set AllFiles=%AllFiles% ..\%Filename:/=\%
    ) 
goto :EOF 

:Combine
type %AllFiles%                   > %OutDebugFile%.temp

@rem Now call Google Closure Compiler to produce a minified version
copy /y version-header.js %OutMinFile%
tools\curl -d output_info=compiled_code -d output_format=text -d compilation_level=ADVANCED_OPTIMIZATIONS --data-urlencode js_code@%OutDebugFile%.temp "http://closure-compiler.appspot.com/compile" > %OutMinFile%.temp

@rem Finalise each file by prefixing with version header and surrounding in function closure
copy /y version-header.js %OutDebugFile%
echo (function(window,undefined){ >> %OutDebugFile%
type %OutDebugFile%.temp		  >> %OutDebugFile%
echo })(window);                  >> %OutDebugFile%
del %OutDebugFile%.temp

copy /y version-header.js %OutMinFile%
echo (function(window,undefined){ >> %OutMinFile%
type %OutMinFile%.temp		  	  >> %OutMinFile%
echo })(window);                  >> %OutMinFile%
del %OutMinFile%.temp

xcopy %OutDebugFile% "..\example\koExternalTemplateEngine.debug.js" /Y
xcopy %OutMinFile% "..\example\koExternalTemplateEngine.js" /Y