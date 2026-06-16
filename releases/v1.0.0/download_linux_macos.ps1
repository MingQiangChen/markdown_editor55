# QLaw Markdown v1.0.0 — Linux & macOS 构建产物下载脚本
# 用法: 右键 > 用 PowerShell 运行

param(
    [ValidateSet("linux","macos","all")]
    [string]`$Platform = "all"
)

$ErrorActionPreference = "Stop"
$headers = @{ Accept = "application/vnd.github+json" }
if (Test-Path env:GITHUB_TOKEN) { $headers["Authorization"] = "Bearer $env:GITHUB_TOKEN" }

$artifacts = @{
    "linux"  = @{ id = 7670677036; name = "linux_x64.zip" };
    "macos"  = @{ id = 7670742990; name = "macos.zip" };
}

$outDir = Split-Path `$PSCommandPath -Parent
$dlUrl = "https://api.github.com/repos/MingQiangChen/markdown_editor55/actions/artifacts/{0}/zip" -f `$artifacts[$p].id

Write-Host "Downloading `$(`$p)..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri `$dlUrl -Headers `$headers -OutFile "`$(`$outDir)/`$(`$artifacts[`$p].name)"
    Write-Host "Done: `$(`$outDir)/`$(`$artifacts[`$p].name)" -ForegroundColor Green
} catch {
    Write-Host "Download failed. Please download manually from:" -ForegroundColor Yellow
    Write-Host "https://github.com/MingQiangChen/markdown_editor55/actions" -ForegroundColor Yellow
}
