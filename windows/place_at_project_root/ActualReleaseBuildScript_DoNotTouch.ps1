if((Test-Path -Path "./android/app/src/main/assets/index.android.*")) {

    Write-Host "Deleting main/assets";

    Remove-Item -Force ./android/app/src/main/assets/index.android.*;

}

if((Test-Path -Path "./android/app/build/intermediates/assets/debug/index.android.*")) {

    Write-Host "Deleting intermediates/assets/debug";

    Remove-Item -Force ./android/app/build/intermediates/assets/debug/index.android.*;

}

if((Test-Path -Path "./android/app/build/intermediates/assets/release/index.android.*")) {

    Write-Host "Deleting intermediates/assets/release";

    Remove-Item -Force ./android/app/build/intermediates/assets/release/index.android.*;

}

Write-Host "Creating Bundle";
react-native bundle --platform android --dev false --entry-file index.js --bundle-output ./android/app/src/main/assets/index.android.bundle --assets-dest ./android/app/src/main/res

Set-Location ./android;

Write-Host "Cleaning Gradle";
Write-Progress -Activity "Cleaning Gradle" -Status "Started";  
./gradlew clean;
Write-Progress -Activity "Cleaning Gradle" -Completed;

Start-Sleep 1;

Write-Host "Creating Release Build";
Write-Progress -Activity "Creating Release Build" -Status "Started";
./gradlew assembleRelease;
Write-Progress -Activity "Creating Release Build" -Completed;