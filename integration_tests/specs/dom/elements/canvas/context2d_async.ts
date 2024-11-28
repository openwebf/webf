describe('Canvas context 2d sync', () => {
  // it('can change size by width and height property', async () => {
  //   var canvas = document.createElement('canvas');
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');
  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

  //   canvas.width = canvas.height = 300;
  //   // Scaled rectangle
  //   context.fillStyle = "red";
  //   context.fillRect(10, 10, 380, 380);

  //   await snapshot();
  //   canvas.width = canvas.height = 400;
  //   // Scaled rectangle
  //   context.fillStyle = "red";
  //   context.fillRect(10, 10, 380, 380);
  //   await snapshot();
  // });

  // it('should work with font and rect', async () => {
  //   var div = document.createElement('div');
  //   div.style.width = div.style.height = '300px';
  //   div.style.backgroundColor = '#eee';

  //   var canvas = document.createElement('canvas');
  //   canvas.style.width = canvas.style.height = '200px';
  //   div.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }
  //   context.font = '24px AlibabaSans';
  //   context.fillStyle = 'green';
  //   context.fillRect(10, 10, 50, 50);
  //   context.clearRect(15, 15, 30, 30);
  //   context.strokeStyle = 'red';
  //   context.strokeRect(40, 40, 100, 100);
  //   context.fillStyle = 'blue';
  //   context.fillText('Hello World', 5.0, 5.0);
  //   context.strokeText('Hello World', 5.0, 25.0);

  //   document.body.appendChild(div);

  //   await snapshot(canvas);
  // });

  fit('should work with lineWidth [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');

    ctx.lineWidth_async = 15;

    ctx.beginPath_async();
    ctx.moveTo_async(20, 20);
    ctx.lineTo_async(130, 130);
    ctx.rect_async(40, 40, 70, 70);
    ctx.stroke_async();
    await snapshot(canvas);
  });

  fit('should work with lineJoin [async]', async () => {
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


  fit('should work with lineCap [async]', async () => {
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

  fit('should work with textAlign [async]', async () => {
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


  // it('should work with miterLimit', async () => {
  //   const canvas = <canvas width="150" height="150" />;
  //   document.body.appendChild(canvas);
  //   const ctx = canvas.getContext('2d');
  //   // Draw guides
  //   ctx.strokeStyle = '#09f';
  //   ctx.lineWidth = 2;
  //   ctx.strokeRect(-5, 50, 160, 50);

  //   // Set line styles
  //   ctx.strokeStyle = '#000';
  //   ctx.lineWidth = 10;

  //   ctx.miterLimit = 10.0;

  //   // Draw lines
  //   ctx.beginPath();
  //   ctx.moveTo(0, 100);
  //   for (var i = 0; i < 24 ; i++) {
  //     var dy = i % 2 == 0 ? 25 : -25;
  //     ctx.lineTo(Math.pow(i, 1.5) * 2, 75 + dy);
  //   }
  //   ctx.stroke();

  //   await snapshot(canvas);
  // });

  fit('should work with ellipse [async]', async () => {
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

  fit('should work with save and restore [async]', async () => {
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

  fit('should work with moveTo and lineTo [async]', async () => {
    const canvas = <canvas height="200" width="200" />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.beginPath_async();
    ctx.moveTo_async(0, 200);
    await ctx.lineTo_async(200, 0);
    ctx.stroke();
    await snapshot(canvas);
  });


  // it('should work with rotate and translate', async () => {
  //   const canvas = <canvas />;
  //   document.body.appendChild(canvas);

  //   const ctx = canvas.getContext('2d');
  //   ctx.fillStyle = 'gray';
  //   ctx.fillRect(80, 60, 140, 30);

  //   // Matrix transformation
  //   ctx.translate(150, 75);
  //   ctx.rotate(Math.PI / 2);
  //   ctx.translate(-150, -75);

  //   // Rotated rectangle
  //   ctx.fillStyle = 'red';
  //   ctx.fillRect(80, 60, 140, 30);
  //   await snapshot(canvas);
  // });

  // it('should work with roundRect', async (done) => {
  //   const canvas = <canvas height="400" width="400" />;
  //   document.body.appendChild(canvas);
  //   const ctx = canvas.getContext('2d');

  //   ctx.scale(0.6, 0.6);

  //   // 半径为零的圆角矩形（指定为数字）
  //   ctx.strokeStyle = "red";
  //   ctx.beginPath();
  //   ctx.roundRect(10, 20, 150, 100, 0);
  //   ctx.stroke();
    
  //   // 半径为 40px 的圆角矩形（单元素列表）
  //   ctx.strokeStyle = "blue";
  //   ctx.beginPath();
  //   ctx.roundRect(10, 20, 150, 100, [40]);
  //   ctx.stroke();
    
  //   // 具有两个不同半径的圆角矩形
  //   ctx.strokeStyle = "orange";
  //   ctx.beginPath();
  //   ctx.roundRect(10, 150, 150, 100, [10, 40]);
  //   ctx.stroke();
    
    
  //   // 具有四个不同半径的圆角矩形
  //   ctx.strokeStyle = "green";
  //   ctx.beginPath();
  //   ctx.roundRect(400, 20, 200, 100, [0, 30, 50, 60]);
  //   ctx.stroke();
    
  //   // 向后绘制的相同矩形
  //   ctx.strokeStyle = "magenta";
  //   ctx.beginPath();
  //   ctx.roundRect(400, 150, -200, -100, [0, 30, 50, 60]);
  //   ctx.stroke();
    
  //   await snapshot(canvas);
  //   done();
  // });

  // it('should work with transform and resetTransform', async () => {
  //   const canvas = <canvas />;
  //   document.body.appendChild(canvas);

  //   const ctx = canvas.getContext('2d');
  //   // Skewed rectangles
  //   ctx.transform(1, 0, 1.7, 1, 0, 0);
  //   ctx.fillStyle = 'blue';
  //   ctx.fillRect(40, 40, 50, 20);
  //   ctx.fillRect(40, 90, 50, 20);

  //   // Non-skewed rectangles
  //   ctx.resetTransform();
  //   ctx.fillStyle = 'red';
  //   ctx.fillRect(40, 40, 50, 20);
  //   ctx.fillRect(40, 90, 50, 20);
  //   await snapshot(canvas);
  // });

  fit('should work with strokeText [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font_async = '50px serif';
    ctx.strokeText_async('Hello world', 50, 90);
    await snapshot(canvas);
  });
  

  fit('should work with fillText [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.font_async = '50px serif';
    ctx.fillText_async('Hello world', 50, 90);
    await snapshot(canvas);
  });

  fit('should work with rect and fill [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    ctx.rect_async(10, 20, 150, 100);
    ctx.fill_async();
    await snapshot(canvas);
  });

  fit('should work with bezierCurveTo [async]', async () => {
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
    ctx.fillStyle = 'blue';
    ctx.beginPath_async();
    ctx.arc_async(start.x, start.y, 5, 0, 2 * Math.PI);  // Start point
    ctx.arc_async(end.x, end.y, 5, 0, 2 * Math.PI);      // End point
    await ctx.fill_async();

    // Control points
    ctx.fillStyle = 'red';
    ctx.beginPath_async();
    ctx.arc_async(cp1.x, cp1.y, 5, 0, 2 * Math.PI);  // Control point one
    ctx.arc_async(cp2.x, cp2.y, 5, 0, 2 * Math.PI);  // Control point two
    ctx.fill_async();
    await snapshot(canvas);
  });

  fit('should work with quadraticCurveTo [async]', async () => {
    const canvas = <canvas />;
    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d');
    // Quadratic Bézier curve
    ctx.beginPath_async();
    ctx.moveTo_async(50, 20);
    ctx.quadraticCurveTo_async(230, 30, 50, 100);
    await ctx.stroke_async();

    // Start and end points
    ctx.fillStyle = 'blue';
    ctx.beginPath_async();
    ctx.arc_async(50, 20, 5, 0, 2 * Math.PI);   // Start point
    ctx.arc_async(50, 100, 5, 0, 2 * Math.PI);  // End point
    await ctx.fill_async();

    // Control point
    ctx.fillStyle = 'red';
    ctx.beginPath_async();
    ctx.arc_async(230, 30, 5, 0, 2 * Math.PI);
    ctx.fill_async();
    await snapshot(canvas);
  });


  // it('should work with fill and fillRect and clearRect', async () => {
  //   const canvas = <canvas />;
  //   document.body.appendChild(canvas);

  //   const ctx = canvas.getContext('2d');
  //   // Draw yellow background
  //   ctx.beginPath();
  //   ctx.fillStyle = '#ff6';
  //   ctx.fillRect(0, 0, canvas.width, canvas.height);

  //   // Draw blue triangle
  //   ctx.beginPath();
  //   ctx.fillStyle = 'blue';
  //   ctx.moveTo(20, 20);
  //   ctx.lineTo(180, 20);
  //   ctx.lineTo(130, 130);
  //   ctx.closePath();
  //   ctx.fill();

  //   // Clear part of the canvas
  //   ctx.clearRect(10, 10, 120, 100);
  //   await snapshot(canvas);
  // });

  // it('should work with clip', async () => {
  //   const canvas = <canvas />;
  //   document.body.appendChild(canvas);

  //   const ctx = canvas.getContext('2d');
  //   // Create circular clipping region
  //   ctx.beginPath();
  //   ctx.arc(100, 75, 50, 0, Math.PI * 2);
  //   ctx.clip();

  //   // Draw stuff that gets clipped
  //   ctx.fillStyle = 'blue';
  //   ctx.fillRect(0, 0, canvas.width, canvas.height);
  //   ctx.fillStyle = 'orange';
  //   ctx.fillRect(0, 0, 100, 100);
  //   await snapshot(canvas);
  // });

  fit('should work with setTransform [async]', async () => {
    const canvas1 = <canvas />;
    const canvas2 = <canvas />;
    document.body.appendChild(canvas1);
    document.body.appendChild(canvas2);

    const ctx1 = canvas1.getContext('2d');
    const ctx2 = canvas2.getContext('2d');

    ctx1.rotate_async(45 * Math.PI / 180);
    ctx1.setTransform_async(1, .2, .8, 1, 0, 0);
    ctx1.fillRect_async(25, 25, 50, 50);

    ctx2.scale_async(9, 3);
    ctx2.setTransform_async(1, .2, .8, 1, 0, 0);
    ctx2.beginPath_async();
    ctx2.arc_async(50, 50, 50, 0, 2 * Math.PI);
    ctx2.fill_async();

    await snapshot();
  });


  fit('should work with drawImage [async]', async (done) => {
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

  // it('should work with reset', async (done) => {
  //   var canvas = document.createElement('canvas');
  //   canvas.style.width = canvas.style.height = '200px';
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }
  //   context.fillStyle = 'yellow';
  //   context.fillRect(0, 0, 100, 100);
  //   context.reset();

  //   context.fillStyle = 'green';
  //   context.fillRect(10, 10, 50, 50);

  //   await snapshot(canvas);
  //   done();
  // });

  fit('should work when draw overflow element [async]', async () => {
    const canvas = document.createElement('canvas')
    canvas.style.width = canvas.style.height = '200px';
    canvas.style.border = '1px solid green';
    canvas.style.padding = '10px';
    canvas.style.margin = '10px';
    canvas.width = canvas.height = 200;

    document.body.appendChild(canvas);

    const ctx = canvas.getContext('2d')!

    ctx.fillStyle = 'green';
    ctx.fillRect_async(10, 10, 200, 200);

    await snapshot();
  });

  // it('should work with createLinearGradient', async (done) => {
  //   const canvas = <canvas height="300" width="300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

  //   const lgd = context.createLinearGradient(20, 0, 220, 0);
	// 	lgd.addColorStop(0, "green");
	// 	lgd.addColorStop(0.5, "cyan");
	// 	lgd.addColorStop(1, "green");

	// 	context.fillStyle = lgd;
	// 	context.fillRect(20, 20, 200, 100);

  //   await snapshot(canvas);
  //   done();
  // });

  // it('should work with createRadialGradient', async (done) => {
  //   const canvas = <canvas height="300" width="300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

	// 	const rgd = context.createRadialGradient(110, 90, 30, 100, 100, 70);
	// 	rgd.addColorStop(0, "pink");
	// 	rgd.addColorStop(0.9, "white");
	// 	rgd.addColorStop(1, "green");

	// 	context.fillStyle = rgd;
	// 	context.fillRect(20, 20, 160, 160);
  //   await snapshot(canvas);
  //   done();
  // });

  // it('should work with createPattern from a canvas when repetition is repeat', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   const patternCanvas = document.createElement("canvas");
  //   const patternContext = patternCanvas.getContext("2d");
  //   if (!patternContext) {
  //     throw new Error('canvas context is null');
  //   }

  //   // Give the pattern a width and height of 50
  //   patternCanvas.width = 50;
  //   patternCanvas.height = 50;

  //   // Give the pattern a background color and draw an arc
  //   patternContext.fillStyle = "#fec";
  //   patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
  //   patternContext.stroke();


  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

  //   const pattern = context.createPattern(patternCanvas, "repeat");
  //   context.fillStyle = pattern;
  //   context.fillRect(0, 0, canvas.width, canvas.height);

  //   await snapshot(canvas);
  //   done();

  // });

  // it('should work with createPattern from a canvas when repetition is repeat-x', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   const patternCanvas = document.createElement("canvas");
  //   const patternContext = patternCanvas.getContext("2d");
  //   if (!patternContext) {
  //     throw new Error('canvas context is null');
  //   }

  //   // Give the pattern a width and height of 50
  //   patternCanvas.width = 50;
  //   patternCanvas.height = 50;

  //   // Give the pattern a background color and draw an arc
  //   patternContext.fillStyle = "#fec";
  //   patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
  //   patternContext.stroke();


  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

  //   const pattern = context.createPattern(patternCanvas, "repeat-x");
  //   context.fillStyle = pattern;
  //   context.fillRect(0, 0, canvas.width, canvas.height);

  //   await snapshot(canvas);
  //   done();

  // });

  // it('should work with createPattern from a canvas when repetition is repeat-y', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   const patternCanvas = document.createElement("canvas");
  //   const patternContext = patternCanvas.getContext("2d");
  //   if (!patternContext) {
  //     throw new Error('canvas context is null');
  //   }

  //   // Give the pattern a width and height of 50
  //   patternCanvas.width = 50;
  //   patternCanvas.height = 50;

  //   // Give the pattern a background color and draw an arc
  //   patternContext.fillStyle = "#fec";
  //   patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
  //   patternContext.stroke();


  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

  //   const pattern = context.createPattern(patternCanvas, "repeat-y");
  //   context.fillStyle = pattern;
  //   context.fillRect(0, 0, canvas.width, canvas.height);

  //   await snapshot(canvas);
  //   done();

  // });

  // it('should work with createPattern from a canvas when repetition is no-repeat', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');

  //   const patternCanvas = document.createElement("canvas");
  //   const patternContext = patternCanvas.getContext("2d");
  //   if (!patternContext) {
  //     throw new Error('canvas context is null');
  //   }

  //   // Give the pattern a width and height of 50
  //   patternCanvas.width = 50;
  //   patternCanvas.height = 50;

  //   // Give the pattern a background color and draw an arc
  //   patternContext.fillStyle = "#fec";
  //   patternContext.arc(0, 0, 50, 0, 0.5 * Math.PI);
  //   patternContext.stroke();


  //   if (!context) {
  //     throw new Error('canvas context is null');
  //   }

  //   const pattern = context.createPattern(patternCanvas, "no-repeat");
  //   context.fillStyle = pattern;
  //   context.fillRect(0, 0, canvas.width, canvas.height);

  //   await snapshot(canvas);
  //   done();

  // });

  // it('should work with createPattern from an image when repetition is repeat', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');


  //   const img = new Image();
  //   img.src = 'assets/cat.png';
  //   // Only use the image after it's loaded
  //   img.onload = async () => {
  //     const pattern = context.createPattern(img, "repeat");
  //     context.fillStyle = pattern;
  //     context.fillRect(0, 0, 300, 300);
  //     await snapshot(canvas);
  //     done();
  //   };

  // })

  // it('should work with createPattern from an image when repetition is repeat-x', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');


  //   const img = new Image();
  //   img.src = 'assets/cat.png';
  //   // Only use the image after it's loaded
  //   img.onload = async () => {
  //     const pattern = context.createPattern(img, "repeat-x");
  //     context.fillStyle = pattern;
  //     context.fillRect(0, 0, 300, 300);
  //     await snapshot(canvas);
  //     done();
  //   };

  // })

  // it('should work with createPattern from an image when repetition is repeat-y', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');


  //   const img = new Image();
  //   img.src = 'assets/cat.png';
  //   // Only use the image after it's loaded
  //   img.onload = async () => {
  //     const pattern = context.createPattern(img, "repeat-y");
  //     context.fillStyle = pattern;
  //     context.fillRect(0, 0, 300, 300);
  //     await snapshot(canvas);
  //     done();
  //   };

  // })

  // it('should work with createPattern from an image when repetition is no-repeat', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');


  //   const img = new Image();
  //   img.src = 'assets/cat.png';
  //   // Only use the image after it's loaded
  //   img.onload = async () => {
  //     const pattern = context.createPattern(img, "no-repeat");
  //     context.fillStyle = pattern;
  //     context.fillRect(0, 0, 300, 300);
  //     await snapshot(canvas);
  //     done();
  //   };

  // })


  fit('should work with create default Path2D [async]', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    path1.rect_async(10, 10, 100, 100);
    context.stroke_async(path1)
    await snapshot(canvas);
    done();

  })

  fit('should work with create Path2D with another Path2D instance [async]', async (done) => {
    const canvas = <canvas height="300" width = "300" />;
    document.body.appendChild(canvas);

    var context = canvas.getContext('2d');    
    let path1 = new Path2D();
    path1.rect_async(10, 10, 100, 100);

    let path2 = new Path2D(path1);
    path2.moveTo_async(220, 60);
    path2.arc_async(170, 60, 50, 0, 2 * Math.PI);
    context.stroke(path2);
    await snapshot(canvas);
    done();

  })

  fit('should work with create Path2D with SVG path data [async]', async (done) => {
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


  // it('should work with create Path2D addPath with DOMMatrix', async (done) => {
  //   const canvas = <canvas height="300" width = "300" />;
  //   document.body.appendChild(canvas);

  //   var context = canvas.getContext('2d');    
    
  //  // Create first path and add a rectangle
  //   let p1 = new Path2D();
  //   p1.rect(0, 0, 100, 150);

  //   // Create second path and add a rectangle
  //   let p2 = new Path2D();
  //   p2.rect(0, 0, 100, 75);

  //   // Create transformation matrix that moves 200 points to the right
  //   let m = new DOMMatrix();
  //   m.a = 1;
  //   m.b = 0;
  //   m.c = 0;
  //   m.d = 1;
  //   m.e = 200;
  //   m.f = 0;

  //   // Add second path to the first path
  //   p1.addPath(p2, m);

  //   // Draw the first path
  //   context.fill(p1);

  //   await snapshot(canvas);
  //   done();
    
  // })

});
