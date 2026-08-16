from pathlib import Path

root = Path(__file__).resolve().parents[1]
gradle = root / 'android/app/build.gradle.kts'
manifest = root / 'android/app/src/main/AndroidManifest.xml'

if gradle.exists():
    g = gradle.read_text(encoding='utf-8')
    if 'isCoreLibraryDesugaringEnabled = true' not in g:
        g = g.replace('compileOptions {', 'compileOptions {\n        isCoreLibraryDesugaringEnabled = true', 1)
    if 'coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:' not in g:
        g += '\n\ndependencies {\n    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")\n}\n'
    gradle.write_text(g, encoding='utf-8')

if manifest.exists():
    m = manifest.read_text(encoding='utf-8')
    perms = [
        '<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />',
        '<uses-permission android:name="android.permission.CAMERA" />',
    ]
    for perm in perms:
        if perm not in m:
            m = m.replace('<application', f'    {perm}\n    <application', 1)
    if 'ScheduledNotificationReceiver' not in m:
        receivers = '''
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED" />
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
            </intent-filter>
        </receiver>
'''
        m = m.replace('</application>', receivers + '    </application>', 1)
    manifest.write_text(m, encoding='utf-8')
