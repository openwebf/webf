/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import fs from "fs";

enum TemplateType {
  header,
  body
}

export class JSONTemplate {
  public raw: string;
  public filename: string;
  public type: TemplateType;
  constructor(source: string, filename: string) {
    this.filename = filename;
    this.type = filename.indexOf('.h') >= 0 ? TemplateType.header : TemplateType.body;
    this.raw = fs.readFileSync(source, {encoding: 'utf-8'})
  }
}
