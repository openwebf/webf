describe('Canvas context 2d async', () => {
  it('can change size by width and height property', async () => {
    var canvas = document.createElement('canvas');
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');
    if (!context) {
      throw new Error('canvas context is null');
    }
    // @ts-ignore
    canvas.width_async = canvas.height_async = 300;
    // Scaled rectangle
    // @ts-ignore
    context.fillStyle_async = "red";
    // @ts-ignore
    context.fillRect_async(10, 10, 380, 380);

    await snapshot();
    // @ts-ignore
    canvas.width_async = canvas.height_async = 400;
    // Scaled rectangle
    // @ts-ignore
    context.fillStyle_async = "red";
    // @ts-ignore
    context.fillRect_async(10, 10, 380, 380);
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
    // @ts-ignore
    context.font_async = '24px AlibabaSans';
    // @ts-ignore
    context.fillStyle_async = 'green';
    // @ts-ignore
    context.fillRect_async(10, 10, 50, 50);
    // @ts-ignore
    context.clearRect_async(15, 15, 30, 30);
    // @ts-ignore
    context.strokeStyle_async = 'red';
    // @ts-ignore
    context.strokeRect_async(40, 40, 100, 100);
    // @ts-ignore
    context.fillStyle_async = 'blue';
    // @ts-ignore
    context.fillText_async('Hello World', 5.0, 5.0);
    // @ts-ignore
    context.strokeText_async('Hello World', 5.0, 25.0);

    document.body.appendChild(div);

    await snapshot(canvas);
  });

  it('should work with lineWidth [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // @ts-ignore
    ctx.lineWidth_async = 15;
    
    ctx.beginPath_async();
    ctx.moveTo_async(20, 20);
    ctx.lineTo_async(130, 130);
    ctx.rect_async(40, 40, 70, 70);
    ctx.stroke_async();
    await snapshot(canvas);
  });

  it('should work with lineJoin [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.lineWidth_async = 20;
    ctx.lineJoin_async = 'round';
    ctx.beginPath_async();
    ctx.moveTo_async(20, 20);
    ctx.lineTo_async(190, 100);
    ctx.lineTo_async(280, 20);
    ctx.lineTo_async(280, 150);
    ctx.stroke_async();
    await snapshot(canvas);
  });


  it('should work with lineCap [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.beginPath_async();
    ctx.moveTo_async(20, 20);
    ctx.lineWidth_async = 15;
    ctx.lineCap_async = 'round';
    ctx.lineTo_async(100, 100);
    ctx.stroke_async();
    await snapshot(canvas);
  });

  it('should work with textAlign [async]', async () => {
    const canvas = <canvas widht="350" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    const x = canvas.width / 2;

    ctx.beginPath_async();
    ctx.moveTo_async(x, 0);
    ctx.lineTo_async(x, canvas.height);
    ctx.stroke_async();

    ctx.font_async = '30px serif';

    ctx.textAlign_async = 'left';
    ctx.fillText_async('left-aligned', x, 40);

    ctx.textAlign_async = 'center';
    ctx.fillText_async('center-aligned', x, 85);

    ctx.textAlign_async = 'right';
    ctx.fillText_async('right-aligned', x, 130);
    await snapshot(canvas);
  });


  it('should work with miterLimit', async () => {
    const canvas = <canvas width="150" height="150" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    // Draw guides
    ctx.strokeStyle_async = '#09f';
    ctx.lineWidth_async = 2;
    ctx.strokeRect_async(-5, 50, 160, 50);

    // Set line styles
    ctx.strokeStyle_async = '#000';
    ctx.lineWidth_async = 10;

    ctx.miterLimit_async = 10.0;

    // Draw lines
    ctx.beginPath_async();
    ctx.moveTo_async(0, 100);
    for (var i = 0; i < 24 ; i++) {
      var dy = i % 2 == 0 ? 25 : -25;
      ctx.lineTo_async(Math.pow(i, 1.5) * 2, 75 + dy);
    }
    ctx.stroke_async();

    await snapshot(canvas);
  });

  it('should work with ellipse [async]', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Draw the ellipse
    ctx.beginPath_async();
    ctx.ellipse_async(100, 100, 50, 75, Math.PI / 4, 0, 2 * Math.PI);
    ctx.stroke_async();
    // Draw the ellipse's line of reflection
    ctx.beginPath_async();
    ctx.moveTo_async(0, 200);
    ctx.lineTo_async(200, 0);
    ctx.stroke_async();
    await snapshot(canvas);
  });

  it('should work with save and restore [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Save the default state
    ctx.save_async();

    ctx.fillStyle_async = 'green';
    ctx.fillRect_async(10, 10, 100, 100);

    // Restore the default state
    ctx.restore_async();

    ctx.fillRect_async(150, 40, 100, 100);
    await snapshot(canvas);
  });

  it('should work with moveTo and lineTo [async]', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.beginPath_async();
    ctx.moveTo_async(0, 200);
    await ctx.lineTo_async(200, 0);
    ctx.stroke();
    await snapshot(canvas);
  });


  it('should work with rotate and translate', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.fillStyle_async = 'gray';
    ctx.fillRect_async(80, 60, 140, 30);

    // Matrix transformation
    ctx.translate_async(150, 75);
    ctx.rotate_async(Math.PI / 2);
    ctx.translate_async(-150, -75);

    // Rotated rectangle
    ctx.fillStyle_async = 'red';
    ctx.fillRect_async(80, 60, 140, 30);
    await snapshot(canvas);
  });

  it('should work with roundRect', async (done) => {
    const canvas = <canvas height="400" width="400" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');

    ctx.scale_async(0.6, 0.6);

    // 半径为零的圆角矩形（指定为数字）
    ctx.strokeStyle_async = "red";
    ctx.beginPat_asynch();
    ctx.roundRect_async(10, 20, 150, 100, 0);
    ctx.stroke_async();
    
    // 半径为 40px 的圆角矩形（单元素列表）
    ctx.strokeStyle_async = "blue";
    ctx.beginPath_async();
    ctx.roundRect_async(10, 20, 150, 100, [40]);
    ctx.stroke_async();
    
    // 具有两个不同半径的圆角矩形
    ctx.strokeStyle_async = "orange";
    ctx.beginPath_async();
    ctx.roundRect_async(10, 150, 150, 100, [10, 40]);
    ctx.stroke_async();
    
    
    // 具有四个不同半径的圆角矩形
    ctx.strokeStyle_async = "green";
    ctx.beginPath_async();
    ctx.roundRect_async(400, 20, 200, 100, [0, 30, 50, 60]);
    ctx.stroke_async();
    
    // 向后绘制的相同矩形
    ctx.strokeStyle_async = "magenta";
    ctx.beginPath_async();
    ctx.roundRect_async(400, 150, -200, -100, [0, 30, 50, 60]);
    ctx.stroke_async();
    
    await snapshot(canvas);
    done();
  });

  it('should work with transform and resetTransform', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Skewed rectangles
    ctx.transform_async(1, 0, 1.7, 1, 0, 0);
    ctx.fillStyle_async = 'blue';
    ctx.fillRect_async(40, 40, 50, 20);
    ctx.fillRect_async(40, 90, 50, 20);

    // Non-skewed rectangles
    ctx.resetTransform_async();
    ctx.fillStyle_async = 'red';
    ctx.fillRect_async(40, 40, 50, 20);
    ctx.fillRect_async(40, 90, 50, 20);
    await snapshot(canvas);
  });

  it('should work with strokeText [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font_async = '50px serif';
    ctx.strokeText_async('Hello world', 50, 90);
    await snapshot(canvas);
  });
  

  it('should work with fillText [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font_async = '50px serif';
    ctx.fillText_async('Hello world', 50, 90);
    await snapshot(canvas);
  });

  it('should work with rect and fill [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.rect_async(10, 20, 150, 100);
    ctx.fill_async();
    await snapshot(canvas);
  });

  it('should work with bezierCurveTo [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Define the points as {x, y}
    let start = { x: 50,    y: 20  };
    let cp1 =   { x: 230,   y: 30  };
    let cp2 =   { x: 150,   y: 80  };
    let end =   { x: 250,   y: 100 };

    // Cubic Bézier curve
    ctx.beginPath_async();
    ctx.moveTo_async(start.x, start.y);
    ctx.bezierCurveTo_async(cp1.x, cp1.y, cp2.x, cp2.y, end.x, end.y);
    await ctx.stroke_async();

    // Start and end points
    ctx.fillStyle_async = 'blue';
    ctx.beginPath_async();
    ctx.arc_async(start.x, start.y, 5, 0, 2 * Math.PI);  // Start point
    ctx.arc_async(end.x, end.y, 5, 0, 2 * Math.PI);      // End point
    ctx.fill_async();

    // Control points
    ctx.fillStyle_async = 'red';
    ctx.beginPath_async();
    ctx.arc_async(cp1.x, cp1.y, 5, 0, 2 * Math.PI);  // Control point one
    ctx.arc_async(cp2.x, cp2.y, 5, 0, 2 * Math.PI);  // Control point two
    ctx.fill_async();
    await snapshot(canvas);
  });

  it('should work with quadraticCurveTo [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Quadratic Bézier curve
    ctx.beginPath_async();
    ctx.moveTo_async(50, 20);
    ctx.quadraticCurveTo_async(230, 30, 50, 100);
    await ctx.stroke_async();

    // Start and end points
    ctx.fillStyle_async = 'blue';
    ctx.beginPath_async();
    ctx.arc_async(50, 20, 5, 0, 2 * Math.PI);   // Start point
    ctx.arc_async(50, 100, 5, 0, 2 * Math.PI);  // End point
    await ctx.fill_async();

    // Control point
    ctx.fillStyle_async = 'red';
    ctx.beginPath_async();
    ctx.arc_async(230, 30, 5, 0, 2 * Math.PI);
    ctx.fill_async();
    await snapshot(canvas);
  });


  it('should work with fill and fillRect and clearRect', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Draw yellow background
    ctx.beginPath_async();
    ctx.fillStyle_async = '#ff6';
    ctx.fillRect_async(0, 0, canvas.width, canvas.height);

    // Draw blue triangle
    ctx.beginPath_async();
    ctx.fillStyle_async = 'blue';
    ctx.moveTo_async(20, 20);
    ctx.lineTo_async(180, 20);
    ctx.lineTo_async(130, 130);
    ctx.closePath_async();
    ctx.fill_async();

    // Clear part of the canvas
    ctx.clearRect_async(10, 10, 120, 100);
    await snapshot(canvas);
  });

  it('should work with clip', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Create circular clipping region
    ctx.beginPath_async();
    ctx.arc_async(100, 75, 50, 0, Math.PI * 2);
    ctx.clip_async();

    // Draw stuff that gets clipped
    ctx.fillStyle_async = 'blue';
    ctx.fillRect_async(0, 0, canvas.width, canvas.height);
    ctx.fillStyle_async = 'orange';
    ctx.fillRect_async(0, 0, 100, 100);
    await snapshot(canvas);
  });

  // it('should work with setTransform [async]', async () => {
  //   const canvas1 = <canvas />;
  //   const canvas2 = <canvas />;
  //   document.body.appendChild(canvas1);
  //   document.body.appendChild(canvas2);

  //   const ctx1 = canvas1.getContext('2d');
  //   const ctx2 = canvas2.getContext('2d');

  //   ctx1.rotate_async(45 * Math.PI / 180);
  //   ctx1.setTransform_async(1, .2, .8, 1, 0, 0);
  //   ctx1.fillRect_async(25, 25, 50, 50);

  //   ctx2.scale_async(9, 3);
  //   ctx2.setTransform_async(1, .2, .8, 1, 0, 0);
  //   ctx2.beginPath_async();
  //   ctx2.arc_async(50, 50, 50, 0, 2 * Math.PI);
  //   ctx2.fill_async();

  //   await snapshot();
  // });


  it('should work with drawImage [async]', async (done) => {
    const canvas = <canvas height="400" width="400" />;
    document.body.appendChild(canvas);
    const ctx = canvas.getContext('2d');
    const img = document.createElement('img');
    img.onload = async () => {
      // drawImage(image, dx, dy)
      ctx.drawImage_async(img, 0, 0);
      // drawImage(image, dx, dy, dWidth, dHeight);
      ctx.drawImage_async(img, 100, 100, 100, 100);
      // drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
      ctx.drawImage_async(img, 20, 20, 20, 20, 200, 200, 100, 100);
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
    // @ts-ignore
    context.fillStyle_async = 'yellow';
    // @ts-ignore
    context.fillRect_async(0, 0, 100, 100);
    // @ts-ignore
    context.reset_async();
    // @ts-ignore
    context.fillStyle_async = 'green';
    // @ts-ignore
    context.fillRect_async(10, 10, 50, 50);

    await snapshot(canvas);
    done();
  });

  it('should work when draw overflow element [async]', async () => {
    const canvas = document.createElement('canvas')
    canvas.style.width = canvas.style.height = '200px';
    canvas.style.border = '1px solid green';
    canvas.style.padding = '10px';
    canvas.style.margin = '10px';
    canvas.width = canvas.height = 200;

    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!

    // @ts-ignore
    ctx.fillStyle_async = 'green';
    // @ts-ignore
    ctx.fillRect_async(10, 10, 200, 200);

    await snapshot();
  });

  it('should work with createLinearGradient', async (done) => {
    const canvas = <canvas height="300" width="300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');

    if (!context) {
      throw new Error('canvas context is null');
    }

    const lgd = await context.createLinearGradient_async(20, 0, 220, 0);
		lgd.addColorStop_asyc(0, "green");
		lgd.addColorStop_asyc(0.5, "cyan");
		lgd.addColorStop_asyc(1, "green");

		context.fillStyle_asyc = lgd;
		context.fillRect_asyc(20, 20, 200, 100);

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
		rgd.addColorStop_asyc(0, "pink");
		rgd.addColorStop_asyc(0.9, "white");
		rgd.addColorStop_asyc(1, "green");

		context.fillStyle_asyc = rgd;
		context.fillRect_asyc(20, 20, 160, 160);
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
    // @ts-ignore
    patternCanvas.width_async = 50;
    // @ts-ignore
    patternCanvas.height_async = 50;

    // Give the pattern a background color and draw an arc
    // @ts-ignore
    patternContext.fillStyle_async = "#fec";
    // @ts-ignore
    patternContext.arc_async(0, 0, 50, 0, 0.5 * Math.PI);
    // @ts-ignore
    patternContext.stroke_async();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern_async(patternCanvas, "repeat");
    context.fillStyle_async = pattern;
    context.fillRect_async(0, 0, canvas.width, canvas.height);

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
    // @ts-ignore
    patternCanvas.width_async = 50;
    // @ts-ignore
    patternCanvas.height_async = 50;

    // Give the pattern a background color and draw an arc
    // @ts-ignore
    patternContext.fillStyle_async = "#fec";
    // @ts-ignore
    patternContext.arc_async(0, 0, 50, 0, 0.5 * Math.PI);
    // @ts-ignore
    patternContext.stroke_async();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern_async(patternCanvas, "repeat-x");
    context.fillStyle_async = pattern;
    context.fillRect_async(0, 0, canvas.width, canvas.height);

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
    // @ts-ignore
    patternCanvas.width_async = 50;
    // @ts-ignore
    patternCanvas.height_async = 50;

    // Give the pattern a background color and draw an arc
    // @ts-ignore
    patternContext.fillStyle_async = "#fec";
    // @ts-ignore
    patternContext.arc_async(0, 0, 50, 0, 0.5 * Math.PI);
    // @ts-ignore
    patternContext.stroke_async();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern_async(patternCanvas, "repeat-y");
    context.fillStyle_async = pattern;
    context.fillRect_async(0, 0, canvas.width, canvas.height);

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
    // @ts-ignore
    patternCanvas.width_async = 50;
    // @ts-ignore
    patternCanvas.height_async = 50;

    // Give the pattern a background color and draw an arc
    // @ts-ignore
    patternContext.fillStyle_async = "#fec";
    // @ts-ignore
    patternContext.arc_async(0, 0, 50, 0, 0.5 * Math.PI);
    // @ts-ignore
    patternContext.stroke_async();


    if (!context) {
      throw new Error('canvas context is null');
    }

    const pattern = context.createPattern_async(patternCanvas, "no-repeat");
    context.fillStyle_async = pattern;
    context.fillRect_async(0, 0, canvas.width, canvas.height);

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
      const pattern = context.createPattern_async(img, "repeat");
      context.fillStyle_async = pattern;
      context.fillRect_async(0, 0, 300, 300);
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
      const pattern = context.createPattern_async(img, "repeat-x");
      context.fillStyle_async = pattern;
      context.fillRect_async(0, 0, 300, 300);
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
      const pattern = context.createPattern_async(img, "repeat-y");
      context.fillStyle_async = pattern;
      context.fillRect_async(0, 0, 300, 300);
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
      const pattern = context.createPattern_async(img, "no-repeat");
      context.fillStyle_async = pattern;
      context.fillRect_async(0, 0, 300, 300);
      await snapshot(canvas);
      done();
    };

  })


  it('should work with create default Path2D [async]', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    // @ts-ignore
    path1.rect_async(10, 10, 100, 100);
    context.stroke_async(path1)
    await snapshot(canvas);
    done();

  })

  it('should work with create Path2D with another Path2D instance [async]', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    // @ts-ignore
    path1.rect_async(10, 10, 100, 100);

    let path2 = new Path2D(path1);
    // @ts-ignore
    path2.moveTo_async(220, 60);
    // @ts-ignore
    path2.arc_async(170, 60, 50, 0, 2 * Math.PI);
    context.stroke(path2);
    await snapshot(canvas);
    done();

  })

  it('should work with create Path2D with SVG path data [async]', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path = new Path2D("M10 10 h 80 v 80 h -80 Z");
    context.fill_async(path);
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
    // @ts-ignore
    p1.rect_async(0, 0, 100, 150);

    // Create second path and add a rectangle
    let p2 = new Path2D();
    // @ts-ignore
    p2.rect_async(0, 0, 100, 75);

    // Create transformation matrix that moves 200 points to the right
    let m = new DOMMatrix();
    // @ts-ignore
    m.a_async = 1;
    // @ts-ignore
    m.b_async = 0;
    // @ts-ignore
    m.c_async = 0;
    // @ts-ignore
    m.d_async = 1;
    // @ts-ignore
    m.e_async = 200;
    // @ts-ignore
    m.f_async = 0;

    // Add second path to the first path
    // @ts-ignore
    p1.addPath_async(p2, m);

    // Draw the first path
    context.fill_async(p1);

    await snapshot(canvas);
    done();
    
  })

});
