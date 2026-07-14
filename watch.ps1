# BioBRB 자동 빌드 & 동기화 스크립트
# 이 스크립트는 네트워크 드라이브의 파일 변경을 감지하고, 로컬 SSD에서 고속 빌드하여 결과를 dist/ 폴더로 자동 갱신합니다.

$localDir = "C:\Users\skept\.gemini\antigravity-ide\scratch\biobrb_local"
$lastBuild = [DateTime]::MinValue

Write-Host "--------------------------------------------------------" -ForegroundColor Cyan
Write-Host "  BioBRB 자동 빌드 & 동기화 감시기가 실행 중입니다..." -ForegroundColor Green
Write-Host "  - 감시 폴더: src/, public/, astro.config.mjs" -ForegroundColor Yellow
Write-Host "  - 빌드 출력: dist/ (http://localhost:8000)" -ForegroundColor Yellow
Write-Host "  - 중단하려면 Ctrl + C 를 누르세요." -ForegroundColor DarkGray
Write-Host "--------------------------------------------------------" -ForegroundColor Cyan

while ($true) {
    # src, public 폴더 및 설정 파일 내의 모든 파일 조회
    $files = Get-ChildItem -Path "src", "public", "astro.config.mjs" -Recurse -File -ErrorAction SilentlyContinue
    
    $needsBuild = $false
    foreach ($file in $files) {
        if ($file.LastWriteTime -gt $lastBuild) {
            $needsBuild = $true
            break
        }
    }
    
    if ($needsBuild) {
        $now = [DateTime]::Now
        Write-Host "`n[$($now.ToString('HH:mm:ss'))] 변경사항 감지! 로컬 SSD 복사 중..." -ForegroundColor Cyan
        
        # 로컬 SSD 복사
        if (Test-Path "src") {
            Copy-Item -Recurse -Force "src" "$localDir\"
        }
        if (Test-Path "public") {
            Copy-Item -Recurse -Force "public" "$localDir\"
        }
        if (Test-Path "astro.config.mjs") {
            Copy-Item -Force "astro.config.mjs" "$localDir\"
        }
        
        Write-Host "[$($now.ToString('HH:mm:ss'))] Astro 정적 빌드 실행 중..." -ForegroundColor Cyan
        
        # 로컬 SSD 폴더에서 astro build 실행
        $p = Start-Process -FilePath "npx.cmd" -ArgumentList "astro", "build" -WorkingDirectory $localDir -NoNewWindow -PassThru -Wait
        
        if ($p.ExitCode -eq 0) {
            Write-Host "[$($now.ToString('HH:mm:ss'))] 빌드 성공! dist 폴더 동기화 중..." -ForegroundColor Green
            # dist 폴더 복사
            New-Item -ItemType Directory -Force -Path "dist" | Out-Null
            Copy-Item -Recurse -Force "$localDir\dist\*" "dist\"
            Write-Host "[$($now.ToString('HH:mm:ss'))] 동기화 완료! 브라우저를 새로고침하세요." -ForegroundColor Green
        } else {
            Write-Warning "[$($now.ToString('HH:mm:ss'))] 빌드 실패 (종료 코드: $($p.ExitCode)). 코드를 점검해 주세요."
        }
        
        $lastBuild = $now
    }
    
    Start-Sleep -Seconds 2
}
