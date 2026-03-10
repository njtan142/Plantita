import { NextRequest, NextResponse } from 'next/server';
import { jwtVerify } from 'jose';

// Function to validate JWT token
async function validateToken(token: string) {
  try {
    const secret = new TextEncoder().encode(process.env.JWT_SECRET);
    await jwtVerify(token, secret);
    return true;
  } catch (error) {
    console.error('Token validation error:', error);
    return false;
  }
}

export async function middleware(req: NextRequest) {
  const url = req.nextUrl.clone();
  const token = req.cookies.get('token')?.value;
  
  console.log('Middleware check:', {
    url: url.pathname,
    hasToken: !!token,
    token: token ? token.substring(0, 20) + '...' : 'none'
  });

  // Allow access to login page and API routes
  if (url.pathname === '/login' || url.pathname.startsWith('/api/')) {
    console.log('Allowing access to login or API route');
    return NextResponse.next();
  }

  // Check if the route is protected (dashboard routes)
  if (url.pathname.startsWith('/dashboard')) {
    if (!token) {
      console.log('No token found, redirecting to login');
      return NextResponse.redirect(new URL('/login', req.url));
    }

    // Validate the token
    const isValid = await validateToken(token);
    
    if (!isValid) {
      console.log('Invalid token, redirecting to login and clearing cookie');
      // Clear invalid token cookie
      const response = NextResponse.redirect(new URL('/login', req.url));
      response.cookies.set('token', '', {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        path: '/',
        maxAge: 0,
        sameSite: 'lax',
      });
      return response;
    }
    
    console.log('Valid token, allowing access to dashboard');
    return NextResponse.next();
  }

  // For all other routes, allow access
  return NextResponse.next();
}

export const config = {
  matcher: ['/dashboard/:path*', '/login'],
};
