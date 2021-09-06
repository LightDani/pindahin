@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
set list="C:\Program Files\*" "C:\Program Files (x86)\*" "C:\Program Files\Common Files\*" "C:\Program Files (x86)\Common Files\*"
set name="CommonFilesDir" "CommonW6432Dir" "ProgramFilesDir" "ProgramW6432Dir" "ProgramFilesDir (x86)" "CommonFilesDir (x86)"

:mulai
    cls
    echo Pilih menu:
    echo 1. Pindah default direktori Program Files
    echo 0. Keluar

    set /p UserInputMenu="Ketik pilihan: "
    if !UserInputMenu!==1 (
        set /p UserInputPath="Pilih root direktori baru (contoh D): "
        set key="HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion" "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion"
        :pindahPF
            cls
            echo Root directori baru yang dipilih: !UserInputPath!
            echo Pilih menu:
            echo 1. Modifikasi regedit
            echo 2. Buat symlink
            echo 99. Kembali
            echo 0. Keluar
            set /p UserInputMenu1="Ketik pilihan: "
            if !UserInputMenu1!==1 (
                :modregPF
                cls
                echo Pilih menu:
                echo 1. Mulai
                echo 2. Restore
                echo 99. Kembali
                echo 0. Keluar
                set /p UserInputMenu11="Ketik pilihan: "
                if !UserInputMenu11!==1 (
                    set /p backup="Backup(y/n)? "
                    set n=1
                    for %%k in (!key!) do (
                        if !backup!==y (
                            rem Backup regedit
                            echo Backing up...
                            reg export %%k ProgramFiles!n!.reg
                            set /A n+=1
                            echo Done. Editing regedit...
                        )
                        rem Edit regedit and make destination folder
                        for %%n in (%name%) do (
                            for /F "delims=: tokens=2" %%A in ('reg query %%k /v %%n') do (
                                set pInstallDir=%%A
                                mkdir "!UserInputPath!:!pInstallDir!"
                                reg add %%k /v %%n /d "!UserInputPath!:!pInstallDir!" /f
                            )
                        )
                    )
                    echo Done
                    timeout 2
                    goto modregPF
                )

                if !UserInputMenu11!==2 (
                    rem Restore
                    for /l %%l in (1,1,2) do (
                        reg import ProgramFiles%%l.reg
                    )
                    echo Done
                    timeout 2
                    goto modregPF
                )

                if !UserInputMenu11!==99 (
                    goto pindahPF
                )

                if !UserInputMenu11!==0 (
                    goto:eof
                ) else (
                    echo Menu tidak tersedia
                    timeout 2
                    goto modregPF
                )
            )

            if !UserInputMenu1!==2 (
                :makeSL
                rem Making symlink
                for /D %%d in (%list%) do (
                    set A=%%d
                    mklink /D "!A:C:=D:!" "!A!"
                )
                echo Done
                timeout 2
                goto pindahPF
            )

            if !UserInputMenu1!==99 (
                    goto mulai
                )

            if !UserInputMenu1!==0 (
                goto:eof
            ) else (
                goto lainnya
            )

    )

    if !UserInputMenu!==0 (
        goto:eof
    ) else (
        echo Menu tidak tersedia
        timeout 2
        goto mulai
    )
