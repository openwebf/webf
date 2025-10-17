// Repro for https://github.com/openwebf/webf/issues/565
// Verify that the counterclockwise (antiClockwise) flag in CanvasRenderingContext2D.arc
// changes the drawn arc/wedge direction.

describe('Canvas arc antiClockwise flag (issue #565)', () => {
  it('draws different wedge areas when antiClockwise toggles', async () => {
    const canvas = document.createElement('canvas');
    canvas.width = 320;
    canvas.height = 160;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!;

    // Background to improve visual diff
    ctx.fillStyle = '#f2f2f2';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Left: clockwise (antiClockwise=false) small 90° wedge in lower-right quadrant
    const cx1 = 80, cy1 = 80, r = 50;
    ctx.fillStyle = '#e11d48'; // red
    ctx.beginPath();
    ctx.moveTo(cx1, cy1);
    ctx.arc(cx1, cy1, r, 0, Math.PI / 2, false);
    ctx.closePath();
    ctx.fill();

    // Right: counterclockwise (antiClockwise=true) large 270° wedge
    const cx2 = 240, cy2 = 80;
    ctx.fillStyle = '#2563eb'; // blue
    ctx.beginPath();
    ctx.moveTo(cx2, cy2);
    ctx.arc(cx2, cy2, r, 0, Math.PI / 2, true);
    ctx.closePath();
    ctx.fill();

    await snapshot(canvas);
  });
});

