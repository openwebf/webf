import React, { useState, useEffect } from 'react';
import { ComparisonResult, ViewMode } from './types';
import { fetchComparisonResults } from './api/client';
import ComparisonList from './components/ComparisonList';
import ViewModeToggle from './components/ViewModeToggle';
import CodePanel from './components/CodePanel';

function App() {
  const [comparisons, setComparisons] = useState<ComparisonResult[]>([]);
  const [viewMode, setViewMode] = useState<ViewMode>('grid');
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selectedSpecFile, setSelectedSpecFile] = useState<string | null>(null);
  const [codePanelOpen, setCodePanelOpen] = useState(false);

  useEffect(() => {
    loadComparisons();
  }, []);

  const loadComparisons = async () => {
    try {
      setLoading(true);
      const results = await fetchComparisonResults();
      setComparisons(results);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to load comparisons');
    } finally {
      setLoading(false);
    }
  };

  const openCodePanel = (specFile: string) => {
    setSelectedSpecFile(specFile);
    setCodePanelOpen(true);
  };

  const closeCodePanel = () => {
    setCodePanelOpen(false);
  };

  return (
    <div className="app">
      <div className="container">
        <h1>🔍 WebF Snapshot Comparison</h1>
        
        <ViewModeToggle 
          viewMode={viewMode} 
          onViewModeChange={setViewMode} 
        />

        {loading && (
          <div className="loading">Loading comparisons...</div>
        )}

        {error && (
          <div className="error">Error loading comparisons: {error}</div>
        )}

        {!loading && !error && (
          <ComparisonList
            comparisons={comparisons}
            viewMode={viewMode}
            onOpenCode={openCodePanel}
          />
        )}
      </div>

      {codePanelOpen && selectedSpecFile && (
        <>
          <div className={`overlay ${codePanelOpen ? 'open' : ''}`} onClick={closeCodePanel} />
          <CodePanel
            specFile={selectedSpecFile}
            isOpen={codePanelOpen}
            onClose={closeCodePanel}
          />
        </>
      )}
    </div>
  );
}

export default App;