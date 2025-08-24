import { ComparisonResult } from '../types';

export async function fetchComparisonResults(): Promise<ComparisonResult[]> {
  const response = await fetch('/api/results');
  if (!response.ok) {
    throw new Error('Failed to fetch comparison results');
  }
  return response.json();
}

export async function fetchSpecContent(specFile: string): Promise<{ content: string; path: string }> {
  const response = await fetch(`/api/spec-content?file=${encodeURIComponent(specFile)}`);
  if (!response.ok) {
    throw new Error('Failed to load spec file');
  }
  return response.json();
}

export async function compileTypeScript(code: string): Promise<string> {
  const response = await fetch('/api/compile-typescript', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code })
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Compilation failed');
  }
  
  const { compiledCode } = await response.json();
  return compiledCode;
}

export async function updateTestPage(code: string, fontFamily?: string, focusedTestIndex?: number): Promise<{ success: boolean; url: string }> {
  const response = await fetch('/api/update-test-page', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ code, fontFamily, focusedTestIndex })
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.error || 'Failed to update test page');
  }
  
  return response.json();
}