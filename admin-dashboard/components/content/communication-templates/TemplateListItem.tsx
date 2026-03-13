'use client';

import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Eye, Edit, Trash2 } from 'lucide-react';
import { CommunicationTemplate } from '@/types/api';

interface TemplateListItemProps {
  template: CommunicationTemplate;
  onPreview: (template: CommunicationTemplate) => void;
  onEdit: (template: CommunicationTemplate) => void;
  onDelete: (template: CommunicationTemplate) => void;
}

export function TemplateListItem({ 
  template, 
  onPreview, 
  onEdit, 
  onDelete 
}: TemplateListItemProps) {
  return (
    <Card className="p-4">
      <div className="flex justify-between items-start">
        <div className="flex-1">
          <div className="flex items-start justify-between">
            <h4 className="font-semibold">{template.name}</h4>
            <Badge variant={template.type === 'email' ? 'default' : 'secondary'}>
              {template.type}
            </Badge>
          </div>
          <p className="text-sm text-muted-foreground mt-1">
            {template.subject}
          </p>
          {template.variables.length > 0 && (
            <div className="flex flex-wrap gap-1 mt-2">
              {template.variables.slice(0, 3).map((variable, index) => (
                <Badge key={index} variant="outline" className="text-xs">
                  {variable}
                </Badge>
              ))}
              {template.variables.length > 3 && (
                <Badge variant="outline" className="text-xs">
                  +{template.variables.length - 3} more
                </Badge>
              )}
            </div>
          )}
        </div>
        <div className="flex gap-1 ml-2">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onPreview(template)}
          >
            <Eye className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onEdit(template)}
          >
            <Edit className="h-4 w-4" />
          </Button>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => onDelete(template)}
          >
            <Trash2 className="h-4 w-4" />
          </Button>
        </div>
      </div>
    </Card>
  );
}
