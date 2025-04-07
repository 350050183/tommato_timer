// 监听模型旋转事件
function setupRotationListener() {
    const modelViewer = document.querySelector('model-viewer');
    if (!modelViewer) return;

    let lastTheta = 0;
    let lastPhi = 0;

    modelViewer.addEventListener('camera-change', () => {
        const orbit = modelViewer.getCameraOrbit();
        const currentTheta = orbit.theta;
        const currentPhi = orbit.phi;

        // 限制phi角度在-90到90度之间
        if (currentPhi > 90) {
            modelViewer.cameraOrbit = `${currentTheta}deg 90deg 75%`;
        } else if (currentPhi < -90) {
            modelViewer.cameraOrbit = `${currentTheta}deg -90deg 75%`;
        }

        if (Math.abs(currentTheta - lastTheta) > 5 || Math.abs(currentPhi - lastPhi) > 5) {
            lastTheta = currentTheta;
            lastPhi = currentPhi;
            RotationChannel.postMessage({
                theta: currentTheta,
                phi: currentPhi
            });
        }
    });
}

// 初始化
document.addEventListener('DOMContentLoaded', setupRotationListener); 