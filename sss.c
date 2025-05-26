#include "raylib-5.5/include/raylib.h"
#include <stdio.h>
#include <unistd.h>
#include <limits.h>

Sound fxWav;
Sound fyWav;
Sound fzWav;

void SSSinit(){
    InitAudioDevice();
    SetMasterVolume(1.0f);
    char cwd[PATH_MAX];
    getcwd(cwd, sizeof(cwd));
    printf("CWD: %s\n", cwd);
    if (!IsAudioDeviceReady())
    {
        printf("WARNING: Audio device not ready!\n");
    }
    else
    {
        printf("Audio device initialised\n");
    }
    fxWav = LoadSound("Hit.wav");
    fyWav = LoadSound("Score.wav");
    fzWav = LoadSound("Win.wav");
}

void SSSplayHit(){
    PlaySound(fxWav);
}
void SSSplayWin(){
    PlaySound(fzWav);
}
void SSSplayScore(){
    PlaySound(fyWav);
}
