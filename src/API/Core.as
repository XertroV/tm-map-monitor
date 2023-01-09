class ClearTask {
    CWebServicesTaskResult@ task;
    CMwNod@ nod;

    CGameUserManagerScript@ userMgr { get { return cast<CGameUserManagerScript>(nod); } }
    CGameDataFileManagerScript@ dataFileMgr { get { return cast<CGameDataFileManagerScript>(nod); } }

    ClearTask(CWebServicesTaskResult@ task, CMwNod@ owner) {
        @this.task = task;
        @nod = owner;
    }

    void Release() {
        if (userMgr !is null) userMgr.TaskResult_Release(task.Id);
        else if (dataFileMgr !is null) dataFileMgr.TaskResult_Release(task.Id);
        else throw("ClearTask.Release called but I don't know how to handle this type: " + Reflection::TypeOf(nod).Name);
    }
}

ClearTask@[] tasksToClear;

// Wait for the task to finish processing, then add it to the list of tasks to be cleared later. Execution returns immediately, so you should consume all data in the task before yielding.
void WaitAndClearTaskLater(CWebServicesTaskResult@ task, CMwNod@ owner) {
    while (task.IsProcessing) yield();
    tasksToClear.InsertLast(ClearTask(task, owner));
}

void ClearTaskCoro() {
    while (true) {
        yield();
        if (tasksToClear.Length == 0) continue;
        for (uint i = 0; i < tasksToClear.Length; i++) {
            tasksToClear[i].Release();
        }
        tasksToClear.RemoveRange(0, tasksToClear.Length);
    }
}

string[]@ GetClubTags(string[]@ wsids) {

    MwFastBuffer<wstring> _wsidList = MwFastBuffer<wstring>();
    for (uint i = 0; i < wsids.Length; i++) {
        _wsidList.Add(wstring(wsids[i]));
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
    // app.MenuManager.MenuCustom_CurrentManiaApp.ScoreMgr.;
    auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Tag_GetClubTagList(userId, _wsidList);
    WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr);
    if (resp.HasFailed || !resp.HasSucceeded) {
        throw('getting club tags failed: ' + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
    }
    string[] tags;
    for (uint i = 0; i < wsids.Length; i++) {
        tags.InsertLast(resp.GetClubTag(wsids[i]));
    }
    return tags;
}

string[]@ GetDisplayNames(string[]@ wsids) {
    MwFastBuffer<wstring> _wsidList = MwFastBuffer<wstring>();
    for (uint i = 0; i < wsids.Length; i++) {
        _wsidList.Add(wstring(wsids[i]));
    }
    auto app = cast<CGameManiaPlanet>(GetApp());
    auto userId = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.Users[0].Id;
    auto resp = app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr.GetDisplayName(userId, _wsidList);
    WaitAndClearTaskLater(resp, app.MenuManager.MenuCustom_CurrentManiaApp.UserMgr);
    if (resp.HasFailed || !resp.HasSucceeded) {
        throw('getting club tags failed: ' + resp.ErrorCode + ", " + resp.ErrorType + ", " + resp.ErrorDescription);
    }
    string[] names;
    for (uint i = 0; i < wsids.Length; i++) {
        names.InsertLast(resp.GetDisplayName(wsids[i]));
    }
    return names;
}
