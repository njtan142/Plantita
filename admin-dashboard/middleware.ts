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
  const token = req.cookies.get('token')?.value;

  if (!token) {
    return NextResponse.redirect(new URL('/login', req.url));
  }

  // Validate the token
  const isValid = await validateToken(token);
  
  if (!isValid) {
    // Clear invalid token cookie
    const response = NextResponse.redirect(new URL('/login', req.url));
    response.cookies.set('token', '', {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      maxAge: 0,
      sameSite: 'strict',
    });
    return response;
  }

  return NextResponse.next();
}

export const config = {
  matcher: '/dashboard/:path*',
};
