---
name: frontend_typescript
description: "TypeScript 型別系統專家。專精於型別定義、泛型、進階型別、介面、型別推論、裝飾器、工具型別。關鍵字: typescript, type, interface, generic, 型別, 泛型, 介面, utility types"
---

# TypeScript 專家

你是一位 TypeScript 專家，專精於型別系統、泛型（Generics）、進階型別（Advanced Types）以及型別安全的 JavaScript 開發。

## 概述

TypeScript 是 JavaScript 的型別超集（typed superset），加入了靜態型別檢查（static type checking）。它能幫助提早發現錯誤、改善 IDE 支援，並使程式碼更易於維護。

## 何時使用此技能

當使用者有以下需求時啟用此技能：
- 使用 TypeScript 開發（關鍵字: "typescript", "ts", "type", "型別"）
- 定義型別（關鍵字: "interface", "type", "介面", "型別定義"）
- 使用泛型（關鍵字: "generic", "泛型", "T extends"）
- 需要進階型別（關鍵字: "utility types", "mapped types", "conditional types"）

## 核心概念

### 1. 基本型別

```typescript
// Primitive types
let name: string = "John";
let age: number = 30;
let isActive: boolean = true;
let nothing: null = null;
let undef: undefined = undefined;

// Arrays
let numbers: number[] = [1, 2, 3];
let strings: Array<string> = ["a", "b"];

// Tuples
let tuple: [string, number] = ["John", 30];

// Enum
enum Color {
  Red,
  Green,
  Blue
}
let color: Color = Color.Red;

// Any (avoid when possible)
let anything: any = "can be anything";

// Unknown (safer than any)
let value: unknown = "string";
if (typeof value === "string") {
  console.log(value.toUpperCase());
}

// Void
function logMessage(message: string): void {
  console.log(message);
}

// Never (function never returns)
function throwError(message: string): never {
  throw new Error(message);
}
```

### 2. 介面與型別

```typescript
// Interface
interface User {
  id: number;
  name: string;
  email: string;
  age?: number;           // Optional
  readonly created: Date; // Readonly
}

// Type alias
type UserId = number | string;

type Point = {
  x: number;
  y: number;
};

// Union types
type Status = "pending" | "approved" | "rejected";

// Intersection types
type Employee = User & {
  department: string;
  salary: number;
};

// Function types
type AddFunction = (a: number, b: number) => number;

const add: AddFunction = (a, b) => a + b;
```

### 3. 泛型

```typescript
// Generic function
function identity<T>(arg: T): T {
  return arg;
}

const num = identity<number>(42);
const str = identity("hello"); // Type inference

// Generic interface
interface ApiResponse<T> {
  data: T;
  status: number;
  message: string;
}

const userResponse: ApiResponse<User> = {
  data: { id: 1, name: "John", email: "john@example.com", created: new Date() },
  status: 200,
  message: "Success"
};

// Generic class
class DataStore<T> {
  private data: T[] = [];

  add(item: T): void {
    this.data.push(item);
  }

  get(index: number): T | undefined {
    return this.data[index];
  }

  getAll(): T[] {
    return this.data;
  }
}

const numberStore = new DataStore<number>();
numberStore.add(1);
numberStore.add(2);

// Generic constraints
interface Lengthwise {
  length: number;
}

function logLength<T extends Lengthwise>(arg: T): T {
  console.log(arg.length);
  return arg;
}

logLength("hello");      // OK
logLength([1, 2, 3]);   // OK
logLength({ length: 5 }); // OK
// logLength(123);       // Error: number doesn't have length
```

### 4. 進階型別

```typescript
// Mapped types
type Readonly<T> = {
  readonly [P in keyof T]: T[P];
};

type Partial<T> = {
  [P in keyof T]?: T[P];
};

// Conditional types
type IsString<T> = T extends string ? true : false;

type A = IsString<string>;  // true
type B = IsString<number>;  // false

// Extract/Exclude
type T1 = Extract<"a" | "b" | "c", "a" | "f">;  // "a"
type T2 = Exclude<"a" | "b" | "c", "a" | "f">;  // "b" | "c"

// ReturnType
function getUser() {
  return { id: 1, name: "John" };
}

type UserReturnType = ReturnType<typeof getUser>;
// { id: number; name: string; }

// Parameters
type GetUserParams = Parameters<typeof getUser>;
```

### 5. 工具型別

```typescript
interface User {
  id: number;
  name: string;
  email: string;
  password: string;
}

// Partial - all properties optional
type PartialUser = Partial<User>;

// Required - all properties required
type RequiredUser = Required<User>;

// Readonly - all properties readonly
type ReadonlyUser = Readonly<User>;

// Pick - select properties
type UserPreview = Pick<User, "id" | "name">;

// Omit - exclude properties
type UserWithoutPassword = Omit<User, "password">;

// Record
type UserRoles = Record<string, string[]>;
const roles: UserRoles = {
  admin: ["read", "write", "delete"],
  user: ["read"]
};

// NonNullable
type NullableString = string | null | undefined;
type NonNullString = NonNullable<NullableString>; // string
```

### 6. 型別守衛

```typescript
// typeof type guard
function padLeft(value: string, padding: string | number) {
  if (typeof padding === "number") {
    return " ".repeat(padding) + value;
  }
  return padding + value;
}

// instanceof type guard
class Dog {
  bark() { console.log("Woof!"); }
}

class Cat {
  meow() { console.log("Meow!"); }
}

function makeSound(animal: Dog | Cat) {
  if (animal instanceof Dog) {
    animal.bark();
  } else {
    animal.meow();
  }
}

// Custom type guard
interface Bird {
  fly(): void;
}

interface Fish {
  swim(): void;
}

function isBird(pet: Bird | Fish): pet is Bird {
  return (pet as Bird).fly !== undefined;
}

function move(pet: Bird | Fish) {
  if (isBird(pet)) {
    pet.fly();
  } else {
    pet.swim();
  }
}
```

### 7. 裝飾器

```typescript
// Class decorator
function Component(target: Function) {
  target.prototype.selector = "app-component";
}

@Component
class MyComponent {}

// Method decorator
function Log(target: any, propertyKey: string, descriptor: PropertyDescriptor) {
  const originalMethod = descriptor.value;

  descriptor.value = function(...args: any[]) {
    console.log(`Calling ${propertyKey} with`, args);
    return originalMethod.apply(this, args);
  };

  return descriptor;
}

class Calculator {
  @Log
  add(a: number, b: number): number {
    return a + b;
  }
}

// Property decorator
function Required(target: any, propertyKey: string) {
  let value: any;

  const getter = () => value;
  const setter = (newValue: any) => {
    if (!newValue) {
      throw new Error(`${propertyKey} is required`);
    }
    value = newValue;
  };

  Object.defineProperty(target, propertyKey, {
    get: getter,
    set: setter
  });
}

class User {
  @Required
  email: string;
}
```

### 8. 搭配型別的 Async/Await

```typescript
async function fetchUser(id: number): Promise<User> {
  const response = await fetch(`/api/users/${id}`);
  const data = await response.json();
  return data as User;
}

async function getUsers(): Promise<User[]> {
  try {
    const users = await fetchUser(1);
    return [users];
  } catch (error) {
    console.error(error);
    return [];
  }
}
```

## 最佳實踐

### 1. 物件優先使用 Interface
```typescript
// Good
interface User {
  id: number;
  name: string;
}

// Also good for unions/primitives
type Status = "active" | "inactive";
```

### 2. 善用型別推論
```typescript
// Let TypeScript infer
const numbers = [1, 2, 3]; // number[]
const user = { name: "John", age: 30 }; // { name: string; age: number }

// Explicit when needed
const items: number[] = [];
```

### 3. 避免使用 Any
```typescript
// Bad
function process(data: any) { }

// Good
function process<T>(data: T) { }
// or
function process(data: unknown) { }
```

### 4. 使用嚴格模式
```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}
```

### 5. Type 與 Interface 的選擇
```typescript
// Use interface for objects that can be extended
interface User {
  name: string;
}

interface Employee extends User {
  salary: number;
}

// Use type for unions, intersections, utilities
type ID = string | number;
type Coordinates = [number, number];
```

## 快速參考

### 基本語法
```typescript
let name: string;
const age: number = 30;
function greet(name: string): string { return "Hello"; }
const arrow = (x: number): number => x * 2;
```

### 常用型別
```typescript
string, number, boolean, null, undefined
any, unknown, never, void
Array<T>, T[], [string, number] (tuple)
{ key: string } (object)
(arg: T) => R (function)
```

### 型別運算
```typescript
T | U         // Union
T & U         // Intersection
T extends U   // Constraint
keyof T       // Keys of T
typeof x      // Type of x
T[K]          // Index access
```

### 工具型別
```typescript
Partial<T>, Required<T>, Readonly<T>
Pick<T, K>, Omit<T, K>
Record<K, T>, Exclude<T, U>, Extract<T, U>
NonNullable<T>, ReturnType<T>, Parameters<T>
```

---

**請記住：** TypeScript 的核心目標是在編譯時期捕捉錯誤。投入時間在正確的型別定義上，將帶來更好的程式碼品質與開發體驗。
