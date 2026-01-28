# setup-profiles.ps1
# Creates directory junctions for profile plugins to reference skills from other plugins.
# Run this script after cloning the repository.

$base = Join-Path $PSScriptRoot "plugins"

$profiles = @{
    "profile_java-personal" = @(
        "core_system-design","core_ddd-delivery","core_microservices",
        "core_spring-boot","core_testing-review",
        "db_schema-design","db_postgresql","db_redis",
        "frontend_vue","frontend_quasar","frontend_typescript",
        "devops_git","devops_docker","devops_cicd",
        "tools_api-docs","tools_chart-generator"
    )
    "profile_java-company" = @(
        "core_pg-standards","core_quarkus","core_testing-review",
        "db_mssql",
        "frontend_quasar","frontend_vue","frontend_typescript",
        "devops_git",
        "tools_api-docs"
    )
}

foreach ($profile in $profiles.Keys) {
    $skillsDir = Join-Path $base (Join-Path $profile "skills")
    if (-not (Test-Path $skillsDir)) {
        New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
    }
    foreach ($skill in $profiles[$profile]) {
        $target = Join-Path $base (Join-Path $skill (Join-Path "skills" $skill))
        $link = Join-Path $skillsDir $skill
        if (Test-Path $link) {
            Remove-Item $link -Force -Recurse
        }
        New-Item -ItemType Junction -Path $link -Target $target -Force | Out-Null
        Write-Host "  $profile -> $skill"
    }
}

Write-Host "`nProfile junctions created successfully."
