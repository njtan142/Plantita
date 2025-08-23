import { NextRequest, NextResponse } from 'next/server';
import axios from 'axios';

export async function POST(req: NextRequest) {
  try {
    const { email, password } = await req.json();

    // Validate input
    if (!email || !password) {
      return NextResponse.json(
        { success: false, message: 'Email and password are required' },
        { status: 400 }
      );
    }

    // Make request to system backend to authenticate user
    const backendUrl = process.env.BACKEND_API_URL || 'http://localhost:3001';
    const response = await axios.post(`${backendUrl}/api/v1/auth/login`, {
      email,
      password
    }, {
      headers: {
        'Content-Type': 'application/json',
      },
      timeout: 10000, // 10 second timeout
    });

    // Check if authentication was successful
    if (response.data.success && response.data.data?.token) {
      const { token, refreshToken, user } = response.data.data;

      // Create response with success data
      const nextResponse = NextResponse.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            username: user.username,
            firstName: user.firstName,
            lastName: user.lastName,
            avatar: user.avatar,
            role: user.role,
            status: user.status || 'active',
            emailVerified: user.emailVerified || false,
            createdAt: user.createdAt,
            updatedAt: user.updatedAt,
          },
          token,
          refreshToken,
          expiresIn: 60 * 60 * 24 * 7, // 1 week
        }
      });

      // Set secure cookies for token and refresh token
      nextResponse.cookies.set('token', token, {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        path: '/',
        maxAge: 60 * 60 * 24 * 7, // 1 week
        sameSite: 'lax', // Changed from 'strict' to 'lax'
      });

      if (refreshToken) {
        nextResponse.cookies.set('refreshToken', refreshToken, {
          httpOnly: true,
          secure: process.env.NODE_ENV === 'production',
          path: '/',
          maxAge: 60 * 60 * 24 * 30, // 1 month
          sameSite: 'lax', // Changed from 'strict' to 'lax'
        });
      }

      return nextResponse;
    } else {
      return NextResponse.json(
        { success: false, message: response.data.message || 'Authentication failed' },
        { status: 401 }
      );
    }
  } catch (error: unknown) {
    console.error('Login error:', error);

    // Handle different types of errors
    if (axios.isAxiosError(error)) {
      if (error.code === 'ECONNREFUSED') {
        return NextResponse.json(
          { success: false, message: 'Unable to connect to authentication server' },
          { status: 503 }
        );
      }

      if (error.response) {
        // Backend returned an error response
        const status = error.response.status;
        const message = error.response.data?.message || 'Authentication failed';
        
        return NextResponse.json(
          { success: false, message },
          { status }
        );
      }
    }

    // Other errors
    return NextResponse.json(
      { success: false, message: 'An unexpected error occurred during authentication' },
      { status: 500 }
    );
  }
}
