@echo off
chcp 65001

set asfFile=""
set amcFile=""
set asfCount=0
set amcCount=0
set unknownCount=0

set fileCount=0
for %%A in (%*) do set /a fileCount+=1

if %fileCount% neq 2 (
    echo 请同时拖拽一个 ASF 文件和一个 AMC 文件到此批处理文件上。
    pause
    exit /b
)

echo.
echo 正在检测拖入的文件类型...
echo.

for %%A in (%*) do (
    echo 文件名： %%A
    echo 文件扩展名： %%~xA

    if /i "%%~xA"==".asf" (
        set /a asfCount+=1
        set asfFile="%%A"
        echo   -  识别为 ASF 文件
    ) else if /i "%%~xA"==".amc" (
        set /a amcCount+=1
        set amcFile="%%A"
        echo   -  识别为 AMC 文件
    ) else (
        set /a unknownCount+=1
        echo 错误：拖入了不支持的文件类型 "%%~xA"。请只拖入 ASF 和 AMC 文件。
        pause
        exit /b
    )
    echo.
)

if %asfCount% neq 1 (
    echo 错误：请只拖入一个 ASF 文件。
    pause
    exit /b
)

if %amcCount% neq 1 (
    echo 错误：请只拖入一个 AMC 文件。
    pause
    exit /b
)

if %unknownCount% neq 0 (
    echo 错误：拖入了不支持的文件类型。请只拖入 ASF 和 AMC 文件。
    pause
    exit /b
)


set amcFilenameNoExt=""
for %%F in ("%amcFile%") do set amcFilenameNoExt=%%~nF

set bvhFilename="%amcFilenameNoExt%.bvh"

echo.
echo 正在使用 ASF 文件： %asfFile%
echo 正在使用 AMC 文件： %amcFile%
echo 导出 BVH 文件名： %bvhFilename%
echo.

set /p frameRate=请输入目标帧率 (FPS，默认30):
if not defined frameRate set frameRate=30

echo.
echo 目标帧率设置为： %frameRate% FPS
echo.

amc2bvh %asfFile% %amcFile% -f %frameRate% -o %bvhFilename%

echo.
echo BVH 文件已成功导出到: %bvhFilename%
echo.

pause