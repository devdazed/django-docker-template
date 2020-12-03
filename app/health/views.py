from rest_framework import viewsets, permissions, status
from rest_framework.response import Response


class HealthViewSet(viewsets.ViewSet):
    # uncomment this to make the endpoint require authentication
    # permission_classes = [permissions.IsAuthenticated]

    def list(self, request, *args, **kwargs):
        """Displays "healthy"
        """
        return Response({'health': 'healthy'}, status=status.HTTP_200_OK)
