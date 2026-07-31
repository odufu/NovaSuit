import React from 'react';
import { ThemeProvider } from '@/core/theme/theme-provider';
import { SalesCallCenterPage } from '@/features/call_center/presentation/pages/SalesCallCenterPage';

export function App() {
  return (
    <ThemeProvider>
      <SalesCallCenterPage />
    </ThemeProvider>
  );
}

export default App;
