// Test prototype chain with deep nesting
function Animal(name) {
  this.name = name;
  this.type = 'animal';
}

Animal.prototype.speak = function() {
  return 'Some sound';
};

Animal.prototype.move = function() {
  return 'Moving';
};

Animal.prototype.animalProp = 'I am an animal';

function Mammal(name, furColor) {
  Animal.call(this, name);
  this.furColor = furColor;
  this.type = 'mammal';
}

// Set up inheritance
Mammal.prototype = Object.create(Animal.prototype);
Mammal.prototype.constructor = Mammal;

Mammal.prototype.nurse = function() {
  return 'Nursing young';
};

Mammal.prototype.mammalProp = 'I am a mammal';

function Dog(name, furColor, breed) {
  Mammal.call(this, name, furColor);
  this.breed = breed;
  this.type = 'dog';
}

// Set up inheritance
Dog.prototype = Object.create(Mammal.prototype);
Dog.prototype.constructor = Dog;

Dog.prototype.bark = function() {
  return 'Woof!';
};

Dog.prototype.wagTail = function() {
  return 'Wagging tail';
};

Dog.prototype.dogProp = 'I am a dog';

// Override speak method
Dog.prototype.speak = function() {
  return 'Woof woof!';
};

// Create instances
const myDog = new Dog('Buddy', 'brown', 'Golden Retriever');
myDog.age = 5;
myDog.favoriteToy = 'ball';

// Test the G/F scenario from the issue
function F() {}
F.prototype.age = 10;
F.prototype.sharedMethod = function() { return 'F method'; };

const f = new F();
f.ownProp = 'f instance';

function G() {}
G.prototype = new F();
G.prototype.constructor = G;  // Properly set constructor
G.prototype.gMethod = function() { return 'G method'; };

const g = new G();
g.instanceProp = 'g instance';

// Also test without fixing constructor
function H() {}
H.prototype = new F();  // Don't fix constructor
const h = new H();
h.hProp = 'h instance';

// Test with Object.create for cleaner prototype chain
function Base() {
  this.baseProp = 'base';
}
Base.prototype.baseMethod = function() { return 'base method'; };

function Derived() {
  Base.call(this);
  this.derivedProp = 'derived';
}
Derived.prototype = Object.create(Base.prototype);
Derived.prototype.constructor = Derived;
Derived.prototype.derivedMethod = function() { return 'derived method'; };

const derived = new Derived();
derived.instanceProp = 'instance';

// Test complex object with various property types
const complexObj = {
  // Primitive properties
  stringProp: 'hello',
  numberProp: 42,
  boolProp: true,
  nullProp: null,
  undefinedProp: undefined,
  
  // Object properties
  objectProp: { nested: 'value', deep: { deeper: 'nested' } },
  arrayProp: [1, 2, 3, { inArray: true }],
  
  // Function properties
  methodProp: function namedMethod() { return 'method'; },
  arrowProp: () => 'arrow',
  
  // Special values
  dateProp: new Date('2024-01-01'),
  regexProp: /test/gi,
  
  // Getter/setter
  get computedProp() { return this.numberProp * 2; },
  set computedProp(val) { this.numberProp = val / 2; }
};

// Add non-enumerable property
Object.defineProperty(complexObj, 'hiddenProp', {
  value: 'hidden',
  enumerable: false,
  configurable: true,
  writable: true
});

// Add symbol properties
const sym = Symbol('mySymbol');
const sym2 = Symbol.for('globalSymbol');
const sym3 = Symbol();  // No description
complexObj[sym] = 'symbol value';
complexObj[sym2] = 'global symbol value';
complexObj[sym3] = 'symbol without description';
complexObj[Symbol.iterator] = function*() { yield 1; yield 2; };

// Log all test objects for inspection
console.log('=== Prototype Chain Test Objects ===');
console.log('myDog:', myDog);
console.log('g (with proper constructor):', g);
console.log('h (without proper constructor):', h);
console.log('derived (using Object.create):', derived);
console.log('complexObj:', complexObj);

// Make objects global for DevTools inspection
window.testObjects = {
  myDog,
  f, g, h,
  derived,
  complexObj,
  Animal, Mammal, Dog,
  F, G, H,
  Base, Derived
};

console.log('Test objects available in window.testObjects');
console.log('Open DevTools and inspect these objects to see prototype chains');