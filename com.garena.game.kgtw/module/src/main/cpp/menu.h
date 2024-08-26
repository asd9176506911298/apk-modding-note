//
// Created by lbert on 4/15/2023.
//

#ifndef ZYGISK_MENU_TEMPLATE_MENU_H
#define ZYGISK_MENU_TEMPLATE_MENU_H

using namespace ImGui;

void DrawMenu()
{
    static ImVec4 clear_color = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);
    {
        Begin(OBFUSCATE("YukiCheats"));

        Checkbox(OBFUSCATE("Map Hack"), &maphack);
        Checkbox(OBFUSCATE("Elsu Aimbot"), &aimbot);
        Checkbox(OBFUSCATE("show skill status"), &heroinfo);
        Checkbox(OBFUSCATE("show hidden profile"), &history);

        Patches();
        End();
    }
}

void SetupImgui() {
    IMGUI_CHECKVERSION();
    CreateContext();

    ImGuiIO &io = GetIO();
    io.DisplaySize = ImVec2((float) glWidth, (float) glHeight);
    ImGui_ImplOpenGL3_Init("#version 100");
    StyleColorsDark();
    GetStyle().ScaleAllSizes(5.0f);
    io.Fonts->AddFontFromMemoryTTF(Roboto_Regular, 30, 30.0f);
}

bool glwh = true;
float glw = 0;
float glh = 0;

EGLBoolean (*old_eglSwapBuffers)(EGLDisplay dpy, EGLSurface surface);
EGLBoolean hook_eglSwapBuffers(EGLDisplay dpy, EGLSurface surface) {
    eglQuerySurface(dpy, surface, EGL_WIDTH, &glWidth);
    eglQuerySurface(dpy, surface, EGL_HEIGHT, &glHeight);

    if (!setupimg)
    {
        SetupImgui();
        setupimg = true;
    }

    ImGuiIO &io = GetIO();

    if(glwh){
        glw=glWidth;
        glh=glHeight;
        glwh= false;
    }
    if(glWidth!=glw){
        float w_w,y_y;
        w_w=(float)glWidth/(float)glw;
        y_y=(float)glHeight/(float)glh;
        //You can adjust it through this
        io.DisplayFramebufferScale=ImVec2(w_w, y_y);
    }

    ImGui_ImplOpenGL3_NewFrame();
    NewFrame();


    DrawMenu();

    EndFrame();
    Render();

//    glViewport(0, 0, (int)io.DisplaySize.x, (int)io.DisplaySize.y);
    glViewport(0, 0, (int)glWidth, (int)glHeight);


    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());
    return old_eglSwapBuffers(dpy, surface);
}

#endif //ZYGISK_MENU_TEMPLATE_MENU_H
