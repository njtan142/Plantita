'use client';

import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';

// This is a mock auth check. In a real app, you would use a proper auth provider.
const useAuth = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Call the API endpoint to check authentication
        const response = await fetch('/api/auth/check');
        const data = await response.json();
        setIsAuthenticated(data.authenticated);
        setLoading(false);
      } catch (error) {
        console.error('Auth check error:', error);
        setIsAuthenticated(false);
        setLoading(false);
      }
    };

    checkAuth();
  }, []);

  return { isAuthenticated, loading };
};

const withAuth = <P extends object>(WrappedComponent: React.ComponentType<P>) => {
  const AuthComponent = (props: P) => {
    const router = useRouter();
    const { isAuthenticated, loading } = useAuth();

    useEffect(() => {
      if (!loading && !isAuthenticated) {
        console.log('Redirecting to login because not authenticated');
        router.push('/login');
      }
    }, [isAuthenticated, loading, router]);

    if (loading) {
      return <div>Loading...</div>; // Or a spinner component
    }

    if (!isAuthenticated) {
      console.log('Not authenticated, returning null');
      return null; // Or a redirect component
    }

    console.log('Authenticated, rendering component');
    return <WrappedComponent {...props} />;
  };

  return AuthComponent;
};

export default withAuth;
