import React from 'react';
import { render, screen, waitFor, fireEvent, act } from '@testing-library/react';
import { CommunicationTemplates } from '../components/content/CommunicationTemplates';
import { communicationService } from '../services/communicationService';
import { MOCK_COMMUNICATION_TEMPLATES } from '../types/api';

// Mock the communication service
jest.mock('../services/communicationService', () => ({
  communicationService: {
    getAllTemplates: jest.fn(),
    getTemplateById: jest.fn(),
    createTemplate: jest.fn(),
    updateTemplate: jest.fn(),
    deleteTemplate: jest.fn(),
  },
}));

// Mock the sonner toast
jest.mock('sonner', () => ({
  toast: {
    success: jest.fn(),
    error: jest.fn(),
    info: jest.fn(),
  },
}));

describe('CommunicationTemplates', () => {
  beforeEach(() => {
    jest.clearAllMocks();
    (communicationService.getAllTemplates as jest.Mock).mockResolvedValue({
      success: true,
      data: MOCK_COMMUNICATION_TEMPLATES,
    });
  });

  it('renders correctly and fetches templates', async () => {
    await act(async () => {
      render(<CommunicationTemplates />);
    });

    expect(screen.getByText('Communication Templates')).toBeInTheDocument();
    
    await waitFor(() => {
      expect(communicationService.getAllTemplates).toHaveBeenCalledTimes(1);
    });

    // Check if mock templates are rendered
    for (const template of MOCK_COMMUNICATION_TEMPLATES) {
      expect(await screen.findByText(template.name)).toBeInTheDocument();
    }
  });

  it('shows error state when fetching fails', async () => {
    (communicationService.getAllTemplates as jest.Mock).mockResolvedValue({
      success: false,
      message: 'Failed to fetch templates error message',
    });

    await act(async () => {
      render(<CommunicationTemplates />);
    });

    expect(await screen.findByText('Failed to fetch templates error message')).toBeInTheDocument();
    expect(screen.getByText('Retry')).toBeInTheDocument();
  });

  it('opens create dialog when "New Template" is clicked', async () => {
    await act(async () => {
      render(<CommunicationTemplates />);
    });

    const newBtn = screen.getByText('New Template');
    
    await act(async () => {
      fireEvent.click(newBtn);
    });

    expect(await screen.findByText('Create New Template')).toBeInTheDocument();
    expect(screen.getByText('Create Template')).toBeInTheDocument();
  });
});
