async function createTask() {
  return Promise.resolve().then(function () {
    new Uint8Array(1000000)
  })
}

run()
async function run() {
  let fn = (v) => { console.log(v.length); }
  let done = (v) => fn(v)
  createTask().then(done)
  const p = new Promise(() => { })
  await p
}