describe('Canvas context 2d', () => {
  it('can change size by width and height property', async () => {
    var canvas = document.createElement('canvas');
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');
    if (!context) {
      throw new Error('canvas context is null');
    }

    canvas.width = canvas.height = 300;
    // Scaled rectangle
    context.fillStyle = "red";
    context.fillRect(10, 10, 380, 380);

    await snapshot();
    canvas.width = canvas.height = 400;
    // Scaled rectangle
    context.fillStyle = "red";
    context.fillRect(10, 10, 380, 380);
    await snapshot();
  });

  it('should work with font and rect', async () => {
    var div = document.createElement('div');
    div.style.width = div.style.height = '300px';
    div.style.backgroundColor = '#eee';

    var canvas = document.createElement('canvas');
    canvas.style.width = canvas.style.height = '200px';
    div.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }
    context.font = '24px AlibabaSans';
    context.fillStyle = 'green';
    context.fillRect(10, 10, 50, 50);
    context.clearRect(15, 15, 30, 30);
    context.strokeStyle = 'red';
    context.strokeRect(40, 40, 100, 100);
    context.fillStyle = 'blue';
    context.fillText('Hello World', 5.0, 5.0);
    context.strokeText('Hello World', 5.0, 25.0);

    document.body.appendChild(div);

    await snapshot(canvas);
  });

  it('should work with lineWidth', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.lineWidth = 15;

    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineTo(130, 130);
    ctx.rect(40, 40, 70, 70);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with lineJoin', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.lineWidth = 20;
    ctx.lineJoin = 'round';
    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineTo(190, 100);
    ctx.lineTo(280, 20);
    ctx.lineTo(280, 150);
    ctx.stroke();
    await snapshot(canvas);
  });


  it('should work with lineCap', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.beginPath();
    ctx.moveTo(20, 20);
    ctx.lineWidth = 15;
    ctx.lineCap = 'round';
    ctx.lineTo(100, 100);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with textAlign', async () => {
    const canvas = <canvas widht="350" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    const x = canvas.width / 2;

    ctx.beginPath();
    ctx.moveTo(x, 0);
    ctx.lineTo(x, canvas.height);
    ctx.stroke();

    ctx.font = '30px serif';

    ctx.textAlign = 'left';
    ctx.fillText('left-aligned', x, 40);

    ctx.textAlign = 'center';
    ctx.fillText('center-aligned', x, 85);

    ctx.textAlign = 'right';
    ctx.fillText('right-aligned', x, 130);
    await snapshot(canvas);
  });


  it('should work with miterLimit', async () => {
    const canvas = <canvas width="150" height="150" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    // Draw guides
    ctx.strokeStyle = '#09f';
    ctx.lineWidth = 2;
    ctx.strokeRect(-5, 50, 160, 50);

    // Set line styles
    ctx.strokeStyle = '#000';
    ctx.lineWidth = 10;

    ctx.miterLimit = 10.0;

    // Draw lines
    ctx.beginPath();
    ctx.moveTo(0, 100);
    for (var i = 0; i < 24 ; i++) {
      var dy = i % 2 == 0 ? 25 : -25;
      ctx.lineTo(Math.pow(i, 1.5) * 2, 75 + dy);
    }
    ctx.stroke();

    await snapshot(canvas);
  });

  it('should work with ellipse', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Draw the ellipse
    ctx.beginPath();
    ctx.ellipse(100, 100, 50, 75, Math.PI / 4, 0, 2 * Math.PI);
    ctx.stroke();
    // Draw the ellipse's line of reflection
    ctx.beginPath();
    ctx.moveTo(0, 200);
    ctx.lineTo(200, 0);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with save and restore', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Save the default state
    ctx.save();

    ctx.fillStyle = 'green';
    ctx.fillRect(10, 10, 100, 100);

    // Restore the default state
    ctx.restore();

    ctx.fillRect(150, 40, 100, 100);
    await snapshot(canvas);
  });

  it('should work with moveTO and lineTo', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.beginPath();
    ctx.moveTo(0, 200);
    ctx.lineTo(200, 0);
    ctx.stroke();
    await snapshot(canvas);
  });

  it('should work with rotate and translate', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.fillStyle = 'gray';
    ctx.fillRect(80, 60, 140, 30);

    // Matrix transformation
    ctx.translate(150, 75);
    ctx.rotate(Math.PI / 2);
    ctx.translate(-150, -75);

    // Rotated rectangle
    ctx.fillStyle = 'red';
    ctx.fillRect(80, 60, 140, 30);
    await snapshot(canvas);
  });

  it('should work with transform and resetTransform', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Skewed rectangles
    ctx.transform(1, 0, 1.7, 1, 0, 0);
    ctx.fillStyle = 'blue';
    ctx.fillRect(40, 40, 50, 20);
    ctx.fillRect(40, 90, 50, 20);

    // Non-skewed rectangles
    ctx.resetTransform();
    ctx.fillStyle = 'red';
    ctx.fillRect(40, 40, 50, 20);
    ctx.fillRect(40, 90, 50, 20);
    await snapshot(canvas);
  });

  it('should work with strokeText', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font = '50px serif';
    ctx.strokeText('Hello world', 50, 90);
    await snapshot(canvas);
  });

  it('should work with fillText', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font = '50px serif';
    ctx.fillText('Hello world', 50, 90);
    await snapshot(canvas);
  });

  it('should work with rect and fill', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.rect(10, 20, 150, 100);
    ctx.fill();
    await snapshot(canvas);
  });

  it('should work with bezierCurveTo', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Define the points as {x, y}
    let start = { x: 50,    y: 20  };
    let cp1 =   { x: 230,   y: 30  };
    let cp2 =   { x: 150,   y: 80  };
    let end =   { x: 250,   y: 100 };

    // Cubic Bézier curve
    ctx.beginPath();
    ctx.moveTo(start.x, start.y);
    ctx.bezierCurveTo(cp1.x, cp1.y, cp2.x, cp2.y, end.x, end.y);
    ctx.stroke();

    // Start and end points
    ctx.fillStyle = 'blue';
    ctx.beginPath();
    ctx.arc(start.x, start.y, 5, 0, 2 * Math.PI);  // Start point
    ctx.arc(end.x, end.y, 5, 0, 2 * Math.PI);      // End point
    ctx.fill();

    // Control points
    ctx.fillStyle = 'red';
    ctx.beginPath();
    ctx.arc(cp1.x, cp1.y, 5, 0, 2 * Math.PI);  // Control point one
    ctx.arc(cp2.x, cp2.y, 5, 0, 2 * Math.PI);  // Control point two
    ctx.fill();
    await snapshot(canvas);
  });

  it('should work with quadraticCurveTo', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Quadratic Bézier curve
    ctx.beginPath();
    ctx.moveTo(50, 20);
    ctx.quadraticCurveTo(230, 30, 50, 100);
    ctx.stroke();

    // Start and end points
    ctx.fillStyle = 'blue';
    ctx.beginPath();
    ctx.arc(50, 20, 5, 0, 2 * Math.PI);   // Start point
    ctx.arc(50, 100, 5, 0, 2 * Math.PI);  // End point
    ctx.fill();

    // Control point
    ctx.fillStyle = 'red';
    ctx.beginPath();
    ctx.arc(230, 30, 5, 0, 2 * Math.PI);
    ctx.fill();
    await snapshot(canvas);
  });

  it('should work with fill and fillRect and clearRect', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Draw yellow background
    ctx.beginPath();
    ctx.fillStyle = '#ff6';
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Draw blue triangle
    ctx.beginPath();
    ctx.fillStyle = 'blue';
    ctx.moveTo(20, 20);
    ctx.lineTo(180, 20);
    ctx.lineTo(130, 130);
    ctx.closePath();
    ctx.fill();

    // Clear part of the canvas
    ctx.clearRect(10, 10, 120, 100);
    await snapshot(canvas);
  });

  it('should work with clip', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Create circular clipping region
    ctx.beginPath();
    ctx.arc(100, 75, 50, 0, Math.PI * 2);
    ctx.clip();

    // Draw stuff that gets clipped
    ctx.fillStyle = 'blue';
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = 'orange';
    ctx.fillRect(0, 0, 100, 100);
    await snapshot(canvas);
  });

  it('should work with setTransform', async () => {
    const canvas1 = <canvas />;
    const canvas2 = <canvas />;
    document.body.appendChild(canvas1);
    document.body.appendChild(canvas2);

    const ctx1 = canvas1.getContext('2d');
    const ctx2 = canvas2.getContext('2d');

    ctx1.rotate(45 * Math.PI / 180);
    ctx1.setTransform(1, .2, .8, 1, 0, 0);
    ctx1.fillRect(25, 25, 50, 50);

    ctx2.scale(9, 3);
    ctx2.setTransform(1, .2, .8, 1, 0, 0);
    ctx2.beginPath();
    ctx2.arc(50, 50, 50, 0, 2 * Math.PI);
    ctx2.fill();

    await snapshot();
  });


  it('should work with drawImage', async (done) => {
    const canvas = <canvas height="400" width="400" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    const img = document.createElement('img');
    img.onload = async () => {
      // drawImage(image, dx, dy)
      ctx.drawImage(img, 0, 0);
      // drawImage(image, dx, dy, dWidth, dHeight);
      ctx.drawImage(img, 100, 100, 100, 100);
      // drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
      ctx.drawImage(img, 20, 20, 20, 20, 200, 200, 100, 100);
      await snapshot(canvas);
      done();
    };
    img.src = 'assets/rabbit.png';
  });

  it('should work with reset', async (done) => {
    var canvas = document.createElement('canvas');
    canvas.style.width = canvas.style.height = '200px';
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }
    context.fillStyle = 'yellow';
    context.fillRect(0, 0, 100, 100);
    context.reset();

    context.fillStyle = 'green';
    context.fillRect(10, 10, 50, 50);

    await snapshot(canvas);
    done();
  });

  it('should work when draw overflow element', async () => {
    const canvas = document.createElement('canvas')
    canvas.style.width = canvas.style.height = '200px';
    canvas.style.border = '1px solid green';
    canvas.style.padding = '10px';
    canvas.style.margin = '10px';
    canvas.width = canvas.height = 200;

    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!

    ctx.fillStyle = 'green';
    ctx.fillRect(10, 10, 200, 200);

    await snapshot();
  });

  it('should work with createLinearGradient', async (done) => {
    const canvas = <canvas height="300" width="300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }

    const lgd = context.createLinearGradient(20, 0, 220, 0);
		lgd.addColorStop(0, "green");
		lgd.addColorStop(0.5, "cyan");
		lgd.addColorStop(1, "green");

		context.fillStyle = lgd;
		context.fillRect(20, 20, 200, 100);

    await snapshot(canvas);
    done();
  });

  it('should work with createRadialGradient', async (done) => {
    const canvas = <canvas height="300" width="300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }

		const rgd = context.createRadialGradient(110, 90, 30, 100, 100, 70);
		rgd.addColorStop(0, "pink");
		rgd.addColorStop(0.9, "white");
		rgd.addColorStop(1, "green");

		context.fillStyle = rgd;
		context.fillRect(20, 20, 160, 160);
    await snapshot(canvas);
    done();
  });

  it('should work with createPattern from a canvas when repetition is repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "repeat");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from a canvas when repetition is repeat-x', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "repeat-x");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from a canvas when repetition is repeat-y', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "repeat-y");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from a canvas when repetition is no-repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    const patternCanvas = document.createElement("canvas");
    const patternContext = patternCanvas.getContext("2d");
    if (!patternContext) {
      throw new Error('canvas context is null');
    }

    // Give the pattern a width and height of 50
    patternCanvas.width = 50;
    patternCanvas.height = 50;

    // Give the pattern a background color and draw an arc
    patternContext.fillStyle = "#fec";
    patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
    patternContext.stroke();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern(patternCanvas, "no-repeat");
    context.fillStyle = pattern;
    context.fillRect(0, 0, canvas.width, canvas.height);

    await snapshot(canvas);
    done();

  });

  it('should work with createPattern from an image when repetition is repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "repeat");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })

  it('should work with createPattern from an image when repetition is repeat-x', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "repeat-x");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })

  it('should work with createPattern from an image when repetition is repeat-y', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "repeat-y");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })

  it('should work with createPattern from an image when repetition is no-repeat', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');


    const img = new Image();
    img.src = 'assets/cat.png';
    // Only use the image after it's loaded
    img.onload = async () => {
      const pattern = context.createPattern(img, "no-repeat");
      context.fillStyle = pattern;
      context.fillRect(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })


  it('should work with create default Path2D', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    path1.rect(10, 10, 100, 100);
    context.stroke(path1)
    await snapshot(canvas);
    done();

  })

  it('should work with create Path2D with another Path2D instance', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    path1.rect(10, 10, 100, 100);

    let path2 = new Path2D(path1);
    path2.moveTo(220, 60);
    path2.arc(170, 60, 50, 0, 2 * Math.PI);
    context.stroke(path2);
    await snapshot(canvas);
    done();

  })

  it('should work with create Path2D with SVG path data', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path = new Path2D("M10 10 h 80 v 80 h -80 Z");
    context.fill(path);
    await snapshot(canvas);
    done();
    
  })

  it('should work with Path2D addPath(path)', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    
   // Create first path and add a rectangle
    let p1 = new Path2D();
    p1.rect(10, 10, 100, 150);

    // Create second path and add a rectangle
    let p2 = new Path2D();
    p2.rect(150, 10, 100, 75);

    // Add second path to the first path
    p1.addPath(p2);

    // Draw the first path
    context.fill(p1);

    await snapshot(canvas);
    done();
    
  })


  it('should work with create Path2D addPath with DOMMatrix', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    
   // Create first path and add a rectangle
    let p1 = new Path2D();
    p1.rect(0, 0, 100, 150);

    // Create second path and add a rectangle
    let p2 = new Path2D();
    p2.rect(0, 0, 100, 75);

    // Create transformation matrix that moves 200 points to the right
    let m = new DOMMatrix();
    m.a = 1;
    m.b = 0;
    m.c = 0;
    m.d = 1;
    m.e = 200;
    m.f = 0;

    // Add second path to the first path
    p1.addPath(p2, m);

    // Draw the first path
    context.fill(p1);

    await snapshot(canvas);
    done();
    
  })

});
