import { Outlet } from 'react-router-dom';
import { ErrorBoundary } from '@/core/components/ErrorBoundary';

export const RootLayout = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      {/* A header could go here */}
      <main className="container mx-auto p-4">
        <ErrorBoundary>
          <Outlet />
        </ErrorBoundary>
      </main>
      {/* A footer could go here */}
    </div>
  );
};
