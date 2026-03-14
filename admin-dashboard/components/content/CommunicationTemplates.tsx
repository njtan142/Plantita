'use client';

import { useState, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { 
  Select, 
  SelectContent, 
  SelectItem, 
  SelectTrigger, 
  SelectValue 
} from '@/components/ui/select';
import { 
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';
import { 
  Badge 
} from '@/components/ui/badge';
import { 
  Skeleton 
} from '@/components/ui/skeleton';
import { 
  Alert, 
  AlertTitle, 
  AlertDescription 
} from '@/components/ui/alert';
import { 
  FileText, 
  Plus, 
  RotateCcw
} from 'lucide-react';
import { communicationService } from '@/services/communicationService';
import { 
  CommunicationTemplate 
} from '@/types/api';
import { toast } from 'sonner';
import { TemplateListItem } from './communication-templates/TemplateListItem';
import { TemplatePreview } from './communication-templates/TemplatePreview';
import { TemplateForm } from './communication-templates/TemplateForm';

interface CommunicationTemplatesProps {
  className?: string;
  onTemplateCreated?: () => void;
  onTemplateUpdated?: () => void;
  onTemplateDeleted?: () => void;
}

export function CommunicationTemplates({ 
  className, 
  onTemplateCreated,
  onTemplateUpdated,
  onTemplateDeleted
}: CommunicationTemplatesProps) {
  const [templates, setTemplates] = useState<CommunicationTemplate[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isCreating, setIsCreating] = useState(false);
  const [editingTemplate, setEditingTemplate] = useState<CommunicationTemplate | null>(null);
  const [deletingTemplate, setDeletingTemplate] = useState<CommunicationTemplate | null>(null);
  const [previewTemplate, setPreviewTemplate] = useState<CommunicationTemplate | null>(null);
  
  // Form state
  const [name, setName] = useState('');
  const [subject, setSubject] = useState('');
  const [body, setBody] = useState('');
  const [type, setType] = useState<'email' | 'notification'>('email');
  const [variables, setVariables] = useState<string[]>(['']);
  
  // Filter state
  const [typeFilter, setTypeFilter] = useState<'all' | 'email' | 'notification'>('all');
  const [searchTerm, setSearchTerm] = useState('');

  useEffect(() => {
    fetchTemplates();
  }, []);

  const fetchTemplates = async () => {
    try {
      setIsLoading(true);
      setError(null);

      const response = await communicationService.getAllTemplates();

      if (response.success && response.data) {
        setTemplates(response.data);
      } else {
        setError(response.message || 'Failed to fetch communication templates');
      }
    } catch (err) {
      console.error('Error fetching templates:', err);
      setError('An unexpected error occurred while fetching templates');
    } finally {
      setIsLoading(false);
    }
  };

  const handleCreateTemplate = async () => {
    if (!name.trim() || !subject.trim() || !body.trim()) {
      toast.error('Validation Error', {
        description: 'Please enter name, subject, and body for the template',
      });
      return;
    }
    
    // Filter out empty variables
    const validVariables = variables.filter(v => v.trim() !== '');
    
    try {
      setIsCreating(true);
      
      const newTemplate = {
        name,
        subject,
        body,
        type,
        variables: validVariables
      };
      
      const response = await communicationService.createTemplate(newTemplate);
      
      if (response.success && response.data) {
        toast.success('Template Created', {
          description: 'Communication template has been created successfully',
        });
        
        // Reset form
        setName('');
        setSubject('');
        setBody('');
        setType('email');
        setVariables(['']);
        
        // Refresh templates
        fetchTemplates();
        onTemplateCreated?.();
      } else {
        throw new Error(response.message || 'Failed to create template');
      }
    } catch (err) {
      console.error('Error creating template:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Creation Failed', {
        description: errorMessage,
      });
    } finally {
      setIsCreating(false);
    }
  };

  const handleUpdateTemplate = async () => {
    if (!editingTemplate) return;
    
    if (!editingTemplate.name.trim() || !editingTemplate.subject.trim() || !editingTemplate.body.trim()) {
      toast.error('Validation Error', {
        description: 'Please enter name, subject, and body for the template',
      });
      return;
    }
    
    // Filter out empty variables
    const validVariables = editingTemplate.variables.filter(v => v.trim() !== '');
    
    try {
      const response = await communicationService.updateTemplate(
        editingTemplate.id,
        {
          name: editingTemplate.name,
          subject: editingTemplate.subject,
          body: editingTemplate.body,
          type: editingTemplate.type,
          variables: validVariables
        }
      );
      
      if (response.success && response.data) {
        toast.success('Template Updated', {
          description: 'Communication template has been updated successfully',
        });
        
        // Close edit dialog and refresh templates
        setEditingTemplate(null);
        fetchTemplates();
        onTemplateUpdated?.();
      } else {
        throw new Error(response.message || 'Failed to update template');
      }
    } catch (err) {
      console.error('Error updating template:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Update Failed', {
        description: errorMessage,
      });
    }
  };

  const handleDeleteTemplate = async () => {
    if (!deletingTemplate) return;
    
    try {
      const response = await communicationService.deleteTemplate(deletingTemplate.id);
      
      if (response.success) {
        toast.success('Template Deleted', {
          description: 'Communication template has been deleted successfully',
        });
        
        // Close delete dialog and refresh templates
        setDeletingTemplate(null);
        fetchTemplates();
        onTemplateDeleted?.();
      } else {
        throw new Error(response.message || 'Failed to delete template');
      }
    } catch (err) {
      console.error('Error deleting template:', err);
      const errorMessage = err instanceof Error ? err.message : 'An unknown error occurred';
      toast.error('Deletion Failed', {
        description: errorMessage,
      });
    }
  };

  const handleRetry = () => {
    fetchTemplates();
  };

  const handleAddVariable = () => {
    setVariables([...variables, '']);
  };

  const handleRemoveVariable = (index: number) => {
    const newVariables = [...variables];
    newVariables.splice(index, 1);
    setVariables(newVariables);
  };

  const handleVariableChange = (index: number, value: string) => {
    const newVariables = [...variables];
    newVariables[index] = value;
    setVariables(newVariables);
  };

  const handleAddVariableToEditing = () => {
    if (editingTemplate) {
      setEditingTemplate({
        ...editingTemplate,
        variables: [...editingTemplate.variables, '']
      });
    }
  };

  const handleRemoveVariableFromEditing = (index: number) => {
    if (editingTemplate) {
      const newVariables = [...editingTemplate.variables];
      newVariables.splice(index, 1);
      setEditingTemplate({
        ...editingTemplate,
        variables: newVariables
      });
    }
  };

  const handleVariableChangeInEditing = (index: number, value: string) => {
    if (editingTemplate) {
      const newVariables = [...editingTemplate.variables];
      newVariables[index] = value;
      setEditingTemplate({
        ...editingTemplate,
        variables: newVariables
      });
    }
  };

  const lowerSearchTerm = searchTerm.toLowerCase();
  const filteredTemplates = templates.filter(template => {
    const matchesType = typeFilter === 'all' || template.type === typeFilter;
    const matchesSearch = template.name.toLowerCase().includes(lowerSearchTerm) ||
                         template.subject.toLowerCase().includes(lowerSearchTerm) ||
                         template.body.toLowerCase().includes(lowerSearchTerm);
    return matchesType && matchesSearch;
  });

  if (error) {
    return (
      <Card className={className}>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span className="flex items-center gap-2">
              <FileText className="h-5 w-5" />
              Communication Templates
            </span>
          </CardTitle>
        </CardHeader>
        <CardContent>
          <Alert variant="destructive">
            <AlertTitle>Error</AlertTitle>
            <AlertDescription className="flex items-center justify-between">
              <span>{error}</span>
              <Button variant="outline" size="sm" onClick={handleRetry}>
                <RotateCcw className="h-4 w-4 mr-2" />
                Retry
              </Button>
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>
    );
  }

  return (
    <Card className={className}>
      <CardHeader>
        <CardTitle className="flex items-center justify-between">
          <span className="flex items-center gap-2">
            <FileText className="h-5 w-5" />
            Communication Templates
          </span>
          <Button onClick={() => setIsCreating(true)} className="flex items-center gap-2">
            <Plus className="h-4 w-4" />
            New Template
          </Button>
        </CardTitle>
      </CardHeader>
      <CardContent>
        {/* Filter Section */}
        <div className="flex flex-col sm:flex-row gap-4 mb-6">
          <div className="flex-1">
            <Input
              placeholder="Search templates..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>
          <div className="w-full sm:w-48">
            <Select value={typeFilter} onValueChange={(value) => setTypeFilter(value as 'all' | 'email' | 'notification')}>
              <SelectTrigger>
                <SelectValue placeholder="Filter by type" />
              </SelectTrigger>
              <SelectContent>
                <SelectItem value="all">All Types</SelectItem>
                <SelectItem value="email">Email</SelectItem>
                <SelectItem value="notification">Notification</SelectItem>
              </SelectContent>
            </Select>
          </div>
        </div>
        
        {/* Create Template Dialog */}
        <AlertDialog open={isCreating} onOpenChange={setIsCreating}>
          <AlertDialogContent className="max-w-2xl">
            <AlertDialogHeader>
              <AlertDialogTitle>Create New Template</AlertDialogTitle>
              <AlertDialogDescription>
                Create a new communication template for messages and notifications.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <TemplateForm
              name={name}
              setName={setName}
              subject={subject}
              setSubject={setSubject}
              body={body}
              setBody={setBody}
              type={type}
              setType={setType}
              variables={variables}
              onAddVariable={handleAddVariable}
              onRemoveVariable={handleRemoveVariable}
              onVariableChange={handleVariableChange}
              idPrefix="create-template"
            />
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleCreateTemplate}
                className="flex items-center gap-2"
              >
                Create Template
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Edit Template Dialog */}
        <AlertDialog open={!!editingTemplate} onOpenChange={(open) => !open && setEditingTemplate(null)}>
          <AlertDialogContent className="max-w-2xl">
            <AlertDialogHeader>
              <AlertDialogTitle>Edit Template</AlertDialogTitle>
              <AlertDialogDescription>
                Edit the communication template details.
              </AlertDialogDescription>
            </AlertDialogHeader>
            {editingTemplate && (
              <TemplateForm
                name={editingTemplate.name}
                setName={(name) => setEditingTemplate({...editingTemplate, name})}
                subject={editingTemplate.subject}
                setSubject={(subject) => setEditingTemplate({...editingTemplate, subject})}
                body={editingTemplate.body}
                setBody={(body) => setEditingTemplate({...editingTemplate, body})}
                type={editingTemplate.type}
                setType={(type) => setEditingTemplate({...editingTemplate, type})}
                variables={editingTemplate.variables}
                onAddVariable={handleAddVariableToEditing}
                onRemoveVariable={handleRemoveVariableFromEditing}
                onVariableChange={handleVariableChangeInEditing}
                idPrefix="edit-template"
              />
            )}
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleUpdateTemplate}
                className="flex items-center gap-2"
              >
                Update Template
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Delete Confirmation Dialog */}
        <AlertDialog open={!!deletingTemplate} onOpenChange={(open) => !open && setDeletingTemplate(null)}>
          <AlertDialogContent>
            <AlertDialogHeader>
              <AlertDialogTitle>Delete Template</AlertDialogTitle>
              <AlertDialogDescription>
                Are you sure you want to delete this template? This action cannot be undone.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction 
                onClick={handleDeleteTemplate}
                className="bg-destructive hover:bg-destructive/90"
              >
                Delete
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Preview Dialog */}
        <AlertDialog open={!!previewTemplate} onOpenChange={(open) => !open && setPreviewTemplate(null)}>
          <AlertDialogContent className="max-w-2xl">
            <AlertDialogHeader>
              <AlertDialogTitle className="flex items-center gap-2">
                <FileText className="h-5 w-5" />
                {previewTemplate?.name}
              </AlertDialogTitle>
              {previewTemplate && (
                <div className="flex flex-wrap gap-2">
                  <Badge variant={previewTemplate.type === 'email' ? 'default' : 'secondary'}>
                    {previewTemplate.type}
                  </Badge>
                </div>
              )}
            </AlertDialogHeader>
            {previewTemplate && (
              <div className="max-h-[60vh] overflow-y-auto pr-2">
                <TemplatePreview template={previewTemplate} />
              </div>
            )}
            <AlertDialogFooter>
              <AlertDialogAction onClick={() => setPreviewTemplate(null)}>
                Close
              </AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
        
        {/* Templates List */}
        <div className="space-y-4">
          <h3 className="text-lg font-semibold">Templates</h3>
          
          {isLoading ? (
            <div className="space-y-3">
              <Skeleton className="h-20 w-full" />
              <Skeleton className="h-20 w-full" />
              <Skeleton className="h-20 w-full" />
            </div>
          ) : filteredTemplates.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <FileText className="h-12 w-12 mx-auto mb-4" />
              <p>No templates found</p>
              <p className="text-sm mt-2">
                {searchTerm || typeFilter !== 'all' 
                  ? 'No templates match your search criteria.' 
                  : 'Create your first template to get started.'}
              </p>
            </div>
          ) : (
            <div className="space-y-3">
              {filteredTemplates.map((template) => (
                <TemplateListItem
                  key={template.id}
                  template={template}
                  onPreview={setPreviewTemplate}
                  onEdit={setEditingTemplate}
                  onDelete={setDeletingTemplate}
                />
              ))}
            </div>
          )}
        </div>
      </CardContent>
    </Card>
  );
}
