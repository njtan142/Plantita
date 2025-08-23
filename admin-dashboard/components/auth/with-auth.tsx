'use client';

import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';

// This is a mock auth check. In a real app, you would use a proper auth provider.
const useAuth = () => {
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const checkAuth = () => {
      // Replace with your actual auth check logic
      const token = localStorage.getItem('authToken');
      setIsAuthenticated(!!token);
      setLoading(false);
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
        router.push('/login');
      }
    }, [isAuthenticated, loading, router]);

    if (loading) {
      return <div>Loading...</div>; // Or a spinner component
    }

    if (!isAuthenticated) {
      return null; // Or a redirect component
    }

    return <WrappedComponent {...props} />;
  };

  return AuthComponent;
};

export default withAuth;
