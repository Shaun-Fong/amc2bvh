@echo off
chcp 65001
SETLOCAL ENABLEDELAYEDEXPANSION

echo.
echo "--------------------------------------"
echo "脚本开始执行"
echo "--------------------------------------"
echo.

echo 尝试接收拖拽文件夹路径参数...
echo 您拖入的文件夹路径是 (%~1 - 原始参数): "%~1"

set targetFolder="%~1"
set targetFolder=%targetFolder:"=%
echo 您拖入的文件夹路径是 (变量 targetFolder - 已移除双引号): "%targetFolder%"
echo.

if not exist "%targetFolder%" (
    echo 错误：指定的文件夹 "%targetFolder%" 不存在。
    pause
    exit /b
)
echo 目标文件夹已确认存在。
echo.

set asfFile=""
set asfCount=0
for /f %%I in ('dir /b /a-d "%targetFolder%\*.asf"') DO set asfFile=%%I
set asfCount=0
if defined asfFile set /a asfCount=1

REM ***  简化 ASF 文件数量检查  ***
if %asfCount% EQU 0 (
    echo 错误：在文件夹 "%targetFolder%" 中，ASF 文件数量不为 1。请确保文件夹内只有一个 ASF 文件。
    pause
    exit /b
)

echo 已找到 ASF 文件（相对路径 - 变量 asfFile）： "%asfFile%"
echo 已找到 ASF 文件（目标文件夹 - 变量 targetFolder）： "%targetFolder%"
set asfFullPath=%targetFolder%\%asfFile%
echo 已找到 ASF 文件（完整路径 - 变量 asfFullPath - 构造后): "%asfFullPath%"
echo 已找到 ASF 文件（完整路径 - 变量 asfFullPath - 再次展开变量查看): %asfFullPath%
echo.


set amcCount=0

REM ***  调试输出：显示 AMC 文件循环之前的 dir 命令  ***
echo 正在执行 AMC 文件查找命令: dir /b /a-d "%targetFolder%\*.amc"

for /f "delims=" %%F in ('dir /b /a-d "%targetFolder%\*.amc"') do (
    set /a amcCount+=1
    set amcFileLoop="%%F"
    REM ***  直接使用 %%~nF 获取不带扩展名的文件名，并显式构造 BVH 文件名和完整路径 ***
    set "amcFilenameNoExt=%%~nF"
    set "bvhFilename=!amcFilenameNoExt!.bvh"
    set "bvhFullPath=%targetFolder%\!bvhFilename!"
    set "amcFullPath=%targetFolder%\%%F"


    echo 正在处理 AMC 文件： %%F
    echo 导出 BVH 文件名: !bvhFilename!
    echo 导出 BVH 完整路径: !bvhFullPath!
    echo 尝试执行 amc2bvh 命令: amc2bvh "%asfFullPath%" "!amcFullPath!" -o "!bvhFullPath!"

    amc2bvh "%asfFullPath%" "!amcFullPath!" -o "!bvhFullPath!"
)

if %amcCount% equ 0 (
    echo 警告：在文件夹 "%targetFolder%" 中未找到任何 AMC 文件。
    echo 没有执行任何转换。
) else (
    echo.
    echo 文件夹 "%targetFolder%" 内的 AMC 文件已全部处理完成，共处理 %amcCount% 个 AMC 文件。
)

pause